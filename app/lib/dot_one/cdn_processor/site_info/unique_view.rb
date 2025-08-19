# frozen_string_literal: true

module DotOne::CdnProcessor::SiteInfo::UniqueView
  class Record < DotOne::CdnProcessor::Base::Record
    def recordable?
      wl_valid? &&
        affiliate_id.present? &&
        uri_stem == '/javascripts/va.adlinks.js'
    end
  end

  class Processor < DotOne::CdnProcessor::Base::Processor
    def add_row(row)
      return false if row.blank?

      record = Record.new(row)

      return false unless record.recordable?

      records[record.affiliate_id] ||= {}
      records[record.affiliate_id][record.http_referer_host_name] ||= {}
      records[record.affiliate_id][record.http_referer_host_name][record.date] ||= { count: 0, recorded_at: [] }
      records[record.affiliate_id][record.http_referer_host_name][record.date][:count] += 1
      records[record.affiliate_id][record.http_referer_host_name][record.date][:recorded_at] << record.recorded_at
      records
    end

    def rollback(batch)
      CDN_LOGGER.info("[#{Time.now}][SiteInfo UniqueView] Rolling back Batch #{batch}")
      UniqueViewStat.where(batch: batch).destroy_all
    end

    def save(batch)
      new_stats = []
      affiliates = Affiliate.where(id: records.keys).index_by(&:id)

      records.each do |affiliate_id, sites|
        affiliate = affiliates[affiliate_id.to_i]

        next if affiliate.blank?

        url_hosts = sites.keys.compact.map { |k| k.dup.prepend('://(www.)?') }
        url_hosts_to_query = url_hosts.join('|')

        next if url_hosts_to_query.blank?

        CDN_LOGGER.info("QUERYING site infos Affiliate: #{affiliate_id} | Host: #{url_hosts.join(', ')}")
        site_infos = affiliate.site_infos.where('url REGEXP ?', url_hosts_to_query).to_a
        site_info_ids = site_infos.map(&:id)

        next if site_info_ids.blank?

        unless affiliate.ad_link_installed_at?
          ad_link_installed_at = sites.values.flat_map(&:values).flat_map { |x| x[:recorded_at] }.sort.min
          affiliate.update_attribute(:ad_link_installed_at, ad_link_installed_at)
        end

        dates = sites.values.flat_map(&:keys)
        stats = UniqueViewStat.where(site_info_id: site_info_ids, date: dates, batch: batch).to_a

        CDN_LOGGER.info("QUERYING existing view stats Affiliate: #{affiliate_id} | Date: #{dates.join(', ')} | Site info ID: #{site_info_ids.join(', ')}")

        sites.each do |site, date_view|
          date_view.each do |date, view_count|
            site_match = site_infos.select { |si| DotOne::Utils::Url.host_name(si.url) == site }
            site_match = site_match.first

            next unless site_match.present?

            site_match.update_column(:verified, true) unless site_match.verified?

            stat = stats.find do |vs|
              vs.site_info_id == site_match.id && vs.date.to_s == date
            end

            if stat.present?
              CDN_LOGGER.info("UPDATING Affiliate: #{affiliate_id} | Site Info: #{site_match.id} | Host: #{site}")
              stat.count += view_count[:count]
              stat.save
            else
              CDN_LOGGER.info("ADDING Affiliate: #{affiliate_id} | Site Info: #{site_match.id} | Host: #{site}")
              new_stats << {
                site_info_id: site_match.id,
                affiliate_id: affiliate_id,
                date: date,
                count: view_count[:count],
                batch: batch,
              }
            end
          end
        end
      end

      CDN_LOGGER.info("INSERTING #{new_stats.length} Site Info Unique View Records")
      UniqueViewStat.import(new_stats)
    end
  end
end
