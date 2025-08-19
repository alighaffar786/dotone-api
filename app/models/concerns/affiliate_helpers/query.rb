module AffiliateHelpers::Query
  extend ActiveSupport::Concern

  included do
    scope :agg_request_count, -> (*network_ids) {
      if network_ids.present?
        network_sql = <<-SQL.squish
          AND offers.network_id in (#{network_ids.flatten.join(',')})
        SQL
      end

      select('affiliates.*, COALESCE(request_agg.count, 0) AS request_count')
        .joins(
          <<-SQL.squish
            LEFT OUTER JOIN
            (
              SELECT affiliate_id, COUNT(affiliate_offers.id) as count FROM affiliate_offers
              JOIN offers ON offers.id = affiliate_offers.offer_id #{network_sql}
              WHERE  affiliate_offers.approval_status = '#{AffiliateOffer.approval_status_active}'
              GROUP BY affiliate_id
            ) AS request_agg ON request_agg.affiliate_id = affiliates.id
          SQL
        )
    }

    scope :select_joined_at, -> (*network_ids) {
      if network_ids.present?
        network_sql = <<-SQL.squish
          AND offers.network_id in (#{network_ids.flatten.join(',')})
        SQL
      end

      select('affiliates.*, applied_offers.last_joined_at')
        .joins(
          <<-SQL.squish
            LEFT OUTER JOIN
            (
              SELECT affiliate_id, MIN(affiliate_offers.created_at) as first_joined_at, MAX(affiliate_offers.created_at) as last_joined_at
              FROM affiliate_offers
              JOIN offers ON offers.id = affiliate_offers.offer_id AND offers.type = 'NetworkOffer' #{network_sql}
              GROUP BY affiliate_id
            ) AS applied_offers ON applied_offers.affiliate_id = affiliates.id
          SQL
        )
    }
  end
end
