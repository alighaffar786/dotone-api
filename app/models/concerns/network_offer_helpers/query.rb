module NetworkOfferHelpers::Query
  extend ActiveSupport::Concern
  include HasAffiliateOffers

  included do
    scope :agg_request_count, -> (*_args) {
      select('COALESCE(request_agg.count, 0) AS request_count, offers.*')
        .joins(
          <<-SQL.squish
            LEFT OUTER JOIN
            (
              SELECT offer_id, COUNT(*) as count FROM affiliate_offers
              WHERE  affiliate_offers.approval_status = '#{AffiliateOffer.approval_status_active}'
              GROUP BY offer_id
            ) AS request_agg ON request_agg.offer_id = offers.id
          SQL
        )
    }

    scope :agg_true_pay, -> (currency_code) {
      rate_sql = Currency.as_rate_sql('conversion_steps.true_currency_id', currency_code)
      select(
        <<-SQL.squish
          offers.*,
          COALESCE(true_pay_agg.max_true_pay, 0) AS max_true_pay,
          COALESCE(true_pay_agg.min_true_pay, 0) AS min_true_pay,
          COALESCE(true_pay_agg.max_true_share, 0) AS max_true_share,
          COALESCE(true_pay_agg.min_true_share, 0) AS min_true_share
        SQL

      ).joins(
        <<-SQL.squish
          LEFT OUTER JOIN
          (
            SELECT
              offer_id,
              MAX(cs_true_pay) AS max_true_pay,
              MIN(cs_true_pay) AS min_true_pay,
              MAX(cs_true_share) AS max_true_share,
              MIN(cs_true_share) AS min_true_share
            FROM (
              SELECT
                conversion_steps.offer_id,
                CASE
                  WHEN conversion_steps.true_conv_type = 'CPS' THEN NULL
                  WHEN conversion_steps.true_pay = 0 THEN cs_schedules.true_pay
                  ELSE COALESCE(cs_schedules.true_pay, conversion_steps.true_pay)
                END * #{rate_sql} AS cs_true_pay,
                CASE
                  WHEN conversion_steps.true_conv_type != 'CPS' THEN NULL
                  WHEN conversion_steps.true_share = 0 THEN cs_schedules.true_share
                  ELSE COALESCE(cs_schedules.true_share, conversion_steps.true_share)
                END AS cs_true_share
              FROM conversion_steps
              LEFT OUTER JOIN
              (
                SELECT
                  owner_id,
                  CAST(substring_index(group_concat(true_pay order by starts_at ASC), ',', 1) AS DECIMAL(20, 2)) as true_pay,
                  CAST(substring_index(group_concat(true_share order by starts_at ASC), ',', 1) AS DECIMAL(8, 2)) as true_share
                FROM pay_schedules
                WHERE owner_type = 'ConversionStep' AND expired is NOT TRUE AND starts_at <= NOW() AND ends_at >= NOW()
                GROUP BY owner_id
              ) AS cs_schedules ON cs_schedules.owner_id = conversion_steps.id
            ) AS t GROUP BY offer_id
          ) AS true_pay_agg ON true_pay_agg.offer_id = offers.id
        SQL
      )
    }
  end

  module ClassMethods
    def select_approval_status(affiliate)
      super(affiliate, :reapply_note, :status_summary, :status_reason, relation: joins(:default_offer_variant))
    end

    def agg_affiliate_pay(user, currency_code)
      super(user, currency_code, relation: joins(:default_offer_variant))
    end
  end
end
