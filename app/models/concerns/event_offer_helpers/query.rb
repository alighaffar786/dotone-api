module EventOfferHelpers::Query
  extend ActiveSupport::Concern

  included do
    scope :select_approval_status, -> (affiliate) {
      return self.none unless affiliate.present?

      select_sql = <<-SQL.squish
        COALESCE(
          CASE
            WHEN offer_variants.status in ('#{OfferVariant.status_considered_active.join("','")}')
              THEN
                CASE
                  WHEN agg_affiliate_offers.approval_status = '#{AffiliateOffer.approval_status_cancelled}' THEN NULL
                  ELSE agg_affiliate_offers.approval_status
                END
            WHEN offer_variants.status = '#{OfferVariant.status_fulfilled}'
              THEN
                CASE
                  WHEN agg_affiliate_offers.approval_status = '#{AffiliateOffer.approval_status_cancelled}' THEN offer_variants.status
                  ELSE COALESCE(agg_affiliate_offers.approval_status, offer_variants.status)
                END
            ELSE offer_variants.status
          END
        , '#{AffiliateOffer.approval_status_apply}') AS approval_status
      SQL

      select(select_sql, 'offers.*')
        .joins(:default_offer_variant)
        .joins(
          <<-SQL.squish
            LEFT OUTER JOIN
              (
                SELECT offer_id, approval_status
                FROM affiliate_offers
                WHERE affiliate_offers.affiliate_id = '#{affiliate.id}'
              ) AS agg_affiliate_offers ON agg_affiliate_offers.offer_id = offers.id
          SQL
        )
    }

    scope :select_forex_total, -> (currency_code) {
      rate = Currency.rate_from_platform(currency_code)
      rate_query = Currency.as_rate_sql('conversion_steps.true_currency_id', currency_code)

      forex_value_sql = <<-SQL.squish
        COALESCE(event_infos.value * #{rate}, 0)
      SQL

      forex_affiliate_pay_sql = <<-SQL.squish
        COALESCE(conversion_steps.affiliate_pay * #{rate_query}, 0)
      SQL

      forex_true_pay_sql = <<-SQL.squish
        COALESCE(conversion_steps.true_pay * #{rate_query}, 0)
      SQL

      select_sql = <<-SQL.squish
        CAST(#{forex_affiliate_pay_sql} AS DECIMAL(20, 2)) AS forex_affiliate_pay,
        CAST(#{forex_true_pay_sql} AS DECIMAL(20, 2)) AS forex_true_pay,
        CAST((#{forex_value_sql} + #{forex_affiliate_pay_sql}) AS DECIMAL(20, 2)) AS forex_total_value
      SQL

      select(select_sql, 'offers.*').left_outer_joins(:default_conversion_step, :event_info)
    }

    scope :agg_request_count, -> {
      select('offers.*, COALESCE(request_agg.count, 0) AS request_count')
        .joins(
          <<-SQL.squish
            LEFT OUTER JOIN
            (
              SELECT offer_id, COUNT(*) AS count FROM affiliate_offers
              WHERE  affiliate_offers.approval_status NOT IN ('#{AffiliateOffer.approval_status_considered_rejected.join("','")}')
              GROUP BY offer_id
            ) AS request_agg ON request_agg.offer_id = offers.id
          SQL
        )
    }

    scope :with_approval_statuses, -> (user, *approval_statuses) {
      ability = user.is_a?(Ability) ? user : Ability.new(user)

      query_affiliate_offers = proc do |params = {}|
        EventAffiliateOfferCollection.new(ability, params).collect
      end

      queries = approval_statuses.flatten.map do |approval_status|
        case approval_status
        when AffiliateOffer.approval_status_apply
          EventOffer
            .joins(:default_offer_variant)
            .where(offer_variants: { status: OfferVariant.status_considered_active })
            .where.not(id: query_affiliate_offers.call.select(:offer_id))
            .select(:id)
        when AffiliateOffer.approval_status_completed
          affiliate_offers = query_affiliate_offers.call(
            approval_statuses: approval_status,
            offer_variant_statuses: OfferVariant.status_considered_positive,
          )
          EventOffer
            .joins(:default_offer_variant)
            .merge(OfferVariant.completed)
            .or(EventOffer.where(id: affiliate_offers.select(:offer_id)))
            .select(:id)
        else
          affiliate_offers = query_affiliate_offers.call(
            approval_statuses: approval_status,
            offer_variant_statuses: OfferVariant.status_considered_active_fulfilled,
          )
          affiliate_offers.select(:offer_id)
        end
      end

      where(queries.map(&:to_sql).map { |query| "offers.id in (#{query})" }.join(' OR '))
    }
  end
end
