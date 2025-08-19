# frozen_string_literal: true

module DotOne::CdnProcessor::AdLink::Impression
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
      records[record.affiliate_id][record.date] ||= { count: 0, recorded_at: [] }
      records[record.affiliate_id][record.date][:count] += 1
      records[record.affiliate_id][record.date][:recorded_at] << record.recorded_at

      true
    end

    def rollback(batch)
      CDN_LOGGER.info("[#{Time.now}][AdLink Impression] Rolling back Batch #{batch}")
      AdLinkStat.where(batch: batch).destroy_all
    end

    def save(batch)
      new_stats = []

      affiliates = Affiliate.where(id: records.keys).index_by(&:id)

      records.each do |affiliate_id, impressions|
        affiliate = affiliates[affiliate_id.to_i]
        stats = AdLinkStat.where(affiliate_id: affiliate_id, date: impressions.keys, batch: batch).to_a

        unless affiliate.ad_link_installed_at?
          ad_link_installed_at = impressions.values.flat_map { |impression| impression[:recorded_at] }.sort.min
          affiliate.update_attribute(:ad_link_installed_at, ad_link_installed_at)
        end

        impressions.each do |date, impression|
          stat = stats.find { |s| s.date.to_s == date.to_s }

          if stat.present?
            CDN_LOGGER.info("UPDATING Affiliate: #{affiliate_id} | Date: #{date}")
            stat.impression += impression[:count]
            stat.save
          else
            new_stats << {
              affiliate_id: affiliate_id,
              date: date,
              impression: impression[:count],
              batch: batch,
            }
          end
        end
      end

      CDN_LOGGER.info("INSERTING #{new_stats.length} AdLink Impression Records")
      AdLinkStat.import(new_stats)
    end
  end
end
