module HasAffiliateOffers
  extend ActiveSupport::Concern

  module ClassMethods
    def select_approval_status(affiliate, *other_fields, relation: self)
      select_field_sqls = other_fields.map do |field|
        field_name, field_alias = field.is_a?(Hash) ? field.flatten : [field, field]

        <<-SQL.squish
          affiliate_offers_join_table.#{field_name} as #{field_alias}
        SQL
      end

      select_field_sql = ", #{select_field_sqls.join(',')}" if other_fields.present?

      relation
        .select(
          <<-SQL.squish
            COALESCE(
              CASE
                WHEN affiliate_offers_join_table.approval_status = '#{AffiliateOffer.approval_status_suspended}'
                  THEN affiliate_offers_join_table.approval_status
                WHEN offer_variants.status in ('#{OfferVariant.status_considered_active.join("','")}')
                  THEN
                    CASE
                      WHEN affiliate_offers_join_table.approval_status = '#{AffiliateOffer.approval_status_cancelled}'
                        THEN '#{AffiliateOffer.approval_status_apply}'
                      ELSE affiliate_offers_join_table.approval_status
                    END
                WHEN offer_variants.status = '#{OfferVariant.status_fulfilled}'
                  THEN
                    CASE
                      WHEN affiliate_offers_join_table.approval_status = '#{AffiliateOffer.approval_status_active}'
                        THEN affiliate_offers_join_table.approval_status
                      ELSE offer_variants.status
                    END
                ELSE offer_variants.status
              END
            , '#{AffiliateOffer.approval_status_apply}') AS approval_status
            #{select_field_sql}
          SQL
        )
        .select("#{table_name}.*")
        .joins(
          <<-SQL.squish
            LEFT OUTER JOIN
              (
                SELECT offer_id, approval_status, reapply_note, status_summary, status_reason
                FROM affiliate_offers
                WHERE affiliate_offers.affiliate_id = '#{affiliate.id}'
              ) AS affiliate_offers_join_table ON affiliate_offers_join_table.offer_id = offers.id
          SQL
        )
    end

    def agg_affiliate_pay(user, currency_code, relation: self)
      if user.is_a?(Affiliate)
        select_sql = <<-SQL.squish
          COALESCE(affiliate_pay_agg.sp_max_affiliate_pay, affiliate_pay_agg.cs_max_affiliate_pay, 0) AS max_affiliate_pay,
          COALESCE(affiliate_pay_agg.sp_min_affiliate_pay, affiliate_pay_agg.cs_min_affiliate_pay, 0) AS min_affiliate_pay,
          COALESCE(affiliate_pay_agg.sp_max_affiliate_share, affiliate_pay_agg.cs_max_affiliate_share, 0) AS max_affiliate_share,
          COALESCE(affiliate_pay_agg.sp_min_affiliate_share, affiliate_pay_agg.cs_min_affiliate_share, 0) AS min_affiliate_share
        SQL

        step_price_query = <<-SQL.squish
          WHERE affiliate_offers.affiliate_id = '#{user.id}'
        SQL
      else
        select_sql = <<-SQL.squish
          GREATEST(
            COALESCE(affiliate_pay_agg.sp_max_affiliate_pay, 0),
            COALESCE(affiliate_pay_agg.cs_max_affiliate_pay, 0)
          ) AS max_affiliate_pay,
          LEAST(
            COALESCE(affiliate_pay_agg.sp_min_affiliate_pay, affiliate_pay_agg.cs_min_affiliate_pay, 0),
            COALESCE(affiliate_pay_agg.cs_min_affiliate_pay, affiliate_pay_agg.sp_min_affiliate_pay, 0)
          ) AS min_affiliate_pay,
          GREATEST(
            COALESCE(affiliate_pay_agg.sp_max_affiliate_share, 0),
            COALESCE(affiliate_pay_agg.cs_max_affiliate_share, 0)
          ) AS max_affiliate_share,
          LEAST(
            COALESCE(affiliate_pay_agg.sp_min_affiliate_share, affiliate_pay_agg.cs_min_affiliate_share, 0),
            COALESCE(affiliate_pay_agg.cs_min_affiliate_share, affiliate_pay_agg.sp_min_affiliate_share, 0)
          ) AS min_affiliate_share
        SQL

        step_price_query = <<-SQL.squish
          WHERE affiliate_offers.approval_status = '#{AffiliateOffer.approval_status_active}'
        SQL
      end

      rate_sql = Currency.as_rate_sql('conversion_steps.true_currency_id', currency_code)

      relation
        .select(select_sql, "#{table_name}.*")
        .joins(
          <<-SQL.squish
            LEFT OUTER JOIN
            (
              SELECT
                offer_id,
                MAX(cs_affiliate_pay) AS cs_max_affiliate_pay,
                MIN(cs_affiliate_pay) AS cs_min_affiliate_pay,
                MAX(sp_max_affiliate_pay) AS sp_max_affiliate_pay,
                MIN(sp_min_affiliate_pay) AS sp_min_affiliate_pay,
                MAX(cs_affiliate_share) AS cs_max_affiliate_share,
                MIN(cs_affiliate_share) AS cs_min_affiliate_share,
                MAX(sp_max_affiliate_share) AS sp_max_affiliate_share,
                MIN(sp_min_affiliate_share) AS sp_min_affiliate_share
              FROM (
                SELECT
                  conversion_steps.offer_id,
                  CASE
                    WHEN conversion_steps.affiliate_conv_type = 'CPS' THEN NULL
                    WHEN conversion_steps.affiliate_pay = 0 THEN cs_schedules.affiliate_pay
                    ELSE COALESCE(cs_schedules.affiliate_pay, conversion_steps.affiliate_pay)
                  END * #{rate_sql} AS cs_affiliate_pay,
                  CASE
                    WHEN conversion_steps.affiliate_conv_type != 'CPS' THEN NULL
                    WHEN conversion_steps.affiliate_share = 0 THEN cs_schedules.affiliate_share
                    ELSE COALESCE(cs_schedules.affiliate_share, conversion_steps.affiliate_share)
                  END AS cs_affiliate_share,
                  CASE
                    WHEN conversion_steps.affiliate_conv_type = 'CPS' THEN NULL
                    WHEN sp.max_affiliate_pay = 0 THEN NULL
                    ELSE sp.max_affiliate_pay
                  END * #{rate_sql} AS sp_max_affiliate_pay,
                  CASE
                    WHEN conversion_steps.affiliate_conv_type = 'CPS' THEN NULL
                    WHEN sp.min_affiliate_pay = 0 THEN NULL
                    ELSE sp.min_affiliate_pay
                  END * #{rate_sql} AS sp_min_affiliate_pay,
                  CASE
                    WHEN conversion_steps.affiliate_conv_type != 'CPS' THEN NULL
                    WHEN sp.max_affiliate_share = 0 THEN NULL
                    ELSE sp.max_affiliate_share
                  END AS sp_max_affiliate_share,
                  CASE
                    WHEN conversion_steps.affiliate_conv_type != 'CPS' THEN NULL
                    WHEN sp.min_affiliate_share = 0 THEN NULL
                    ELSE sp.min_affiliate_share
                  END AS sp_min_affiliate_share
                FROM conversion_steps
                LEFT OUTER JOIN
                (
                  SELECT
                    owner_id,
                    CAST(substring_index(group_concat(affiliate_pay order by starts_at ASC), ',', 1) AS DECIMAL(20, 2)) as affiliate_pay,
                    CAST(substring_index(group_concat(affiliate_share order by starts_at ASC), ',', 1) AS DECIMAL(8, 2)) as affiliate_share
                  FROM pay_schedules
                  WHERE owner_type = 'ConversionStep' AND expired is NOT TRUE AND starts_at <= NOW() AND ends_at >= NOW()
                  GROUP BY owner_id
                ) AS cs_schedules ON cs_schedules.owner_id = conversion_steps.id
                LEFT OUTER JOIN
                (
                  SELECT
                    step_prices.conversion_step_id,
                    COALESCE(MAX(sp_schedules.affiliate_pay), MAX(step_prices.custom_amount)) AS max_affiliate_pay,
                    COALESCE(MIN(sp_schedules.affiliate_pay), MIN(step_prices.custom_amount)) AS min_affiliate_pay,
                    COALESCE(MAX(sp_schedules.affiliate_share), MAX(step_prices.custom_share)) AS max_affiliate_share,
                    COALESCE(MIN(sp_schedules.affiliate_share), MIN(step_prices.custom_share)) AS min_affiliate_share
                  FROM step_prices
                  LEFT OUTER JOIN affiliate_offers ON affiliate_offers.id = step_prices.affiliate_offer_id
                  LEFT OUTER JOIN
                  (
                    SELECT
                      owner_id,
                      CAST(substring_index(group_concat(affiliate_pay order by starts_at ASC), ',', 1) AS DECIMAL(20, 2)) as affiliate_pay,
                      CAST(substring_index(group_concat(affiliate_share order by starts_at ASC), ',', 1) AS DECIMAL(8, 2)) as affiliate_share
                    FROM pay_schedules
                    WHERE owner_type = 'StepPrice' AND expired is NOT TRUE AND starts_at <= NOW() AND ends_at >= NOW()
                    GROUP BY owner_id
                  ) AS sp_schedules ON sp_schedules.owner_id = step_prices.id
                  #{step_price_query}
                  GROUP BY step_prices.conversion_step_id
                ) AS sp ON sp.conversion_step_id = conversion_steps.id
              ) AS t GROUP BY offer_id
            ) AS affiliate_pay_agg ON affiliate_pay_agg.offer_id = offers.id
          SQL
        )
    end

    def with_approval_statuses(user, *approval_statuses, relation: self)
      ability = user.is_a?(Ability) ? user : Ability.new(user)

      query_affiliate_offers = proc do |params = {}|
        AffiliateOfferCollection.new(ability, params).collect
      end

      queries = approval_statuses.flatten.map do |approval_status|
        case approval_status
        when AffiliateOffer.approval_status_apply
          NetworkOffer
            .joins(:default_offer_variant)
            .where(need_approval: true)
            .where(offer_variants: { status: OfferVariant.status_considered_active })
            .where.not(id: query_affiliate_offers.call.select(:offer_id))
            .select(:id)
        when AffiliateOffer.approval_status_active
          affiliate_offers = query_affiliate_offers.call(
            approval_statuses: approval_status,
            offer_variant_statuses: OfferVariant.status_considered_active_fulfilled,
          )
          affiliate_offers.select(:offer_id)
        when AffiliateOffer.approval_status_suspended
          affiliate_offers = query_affiliate_offers.call(approval_statuses: approval_status)
          affiliate_offers.select(:offer_id)
        when AffiliateOffer.approval_status_paused
          affiliate_offers = query_affiliate_offers
            .call(offer_variant_statuses: OfferVariant.status_paused)
            .where.not(approval_status: AffiliateOffer.approval_status_suspended)
          affiliate_offers = affiliate_offers.or(query_affiliate_offers.call(approval_statuses: approval_status).joins(:default_offer_variant))
          affiliate_offers.select(:offer_id)
        else
          affiliate_offers = query_affiliate_offers.call(
            approval_statuses: approval_status,
            offer_variant_statuses: OfferVariant.status_considered_active,
          )
          affiliate_offers.select(:offer_id)
        end
      end

      relation.where(queries.map(&:to_sql).map { |query| "offers.id in (#{query})" }.join(' OR '))
    end
  end
end
