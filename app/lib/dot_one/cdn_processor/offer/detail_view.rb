# frozen_string_literal: true

module DotOne::CdnProcessor::Offer::DetailView
  TRACK_NAME = 'offer-detail-view'

  class Record < DotOne::CdnProcessor::Base::Record
    def recordable?
      wl_valid? &&
        offer_id.present? &&
        track == TRACK_NAME &&
        http_host == 'cdn.affiliates.one' &&
        uri_stem == '/1x1.gif'
    end
  end

  class Processor < DotOne::CdnProcessor::Base::Processor
    def add_row(row)
      return false if row.blank?

      record = Record.new(row)

      return false unless record.recordable?

      records[record.offer_id] ||= {}
      records[record.offer_id][record.date] ||= 0
      records[record.offer_id][record.date] += 1

      true
    end

    def rollback(batch)
      CDN_LOGGER.info("[#{Time.now}][Offer DetailView] Rolling back Batch #{batch}")
      OfferStat.where(batch: batch).destroy_all
    end

    def save(batch)
      new_stats = []

      records.each do |offer_id, views|
        stats = OfferStat
          .where(offer_id: offer_id, date: views.keys, batch: batch)
          .index_by(&:date)
          .transform_keys(&:to_s)

        views.each do |date, count|
          stat = stats[date]

          if stat.present?
            CDN_LOGGER.info("UPDATING Offer: #{offer_id} | Date: #{date}")
            stat.detail_view_count += count
            stat.save
          else
            new_stats << {
              offer_id: offer_id,
              date: date,
              detail_view_count: count,
              batch: batch,
            }
          end
        end
      end

      CDN_LOGGER.info("INSERTING #{new_stats.length} Offer Detail View Records")
      OfferStat.import(new_stats)
    end
  end
end
