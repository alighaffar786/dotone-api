module StatHelpers::Query
  extend ActiveSupport::Concern

  module ClassMethods
    def valid_status_sql(user_role = :affiliate, condition = nil)
      return unless user_role == :affiliate

      <<-SQL.squish
        #{condition} (status != '#{Order.status_beyond_referral_period}' OR status IS NULL)
      SQL
    end

    def beyond_referral_period_rule_sql
      <<-SQL.squish
        (#{valid_status_sql}) OR
        (status = '#{Order.status_beyond_referral_period}' AND approval IN ('#{AffiliateStat.approvals_publishable.join("','")}'))
      SQL
    end

    def date_sql(date_column = :recorded_at, period = :day, time_zone = TimeZone.default)
      <<-SQL.squish
        DATE_TRUNC(
          '#{period}', DATE(CONVERT_TIMEZONE('UTC', 'UTC #{time_zone.offset_string}', stats.#{date_column}))
        )
      SQL
    end

    def impressions_sql(**options)
      <<-SQL.squish
        SUM(COALESCE(impression, 0))
      SQL
    end

    def clicks_sql(**options)
      <<-SQL.squish
        SUM(COALESCE(clicks, 0))
      SQL
    end

    def captured_sql(user_role: nil, **options)
      if user_role == :affiliate
        <<-SQL.squish
          SUM(
            CASE WHEN (#{beyond_referral_period_rule_sql})
            THEN COALESCE(conversions, 0) ELSE 0 END
          )
        SQL
      else
        <<-SQL.squish
          SUM(COALESCE(conversions, 0))
        SQL
      end
    end

    def published_conversions_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_publishable.join("','")}')
          THEN COALESCE(conversions, 0) ELSE 0 END
        )
      SQL
    end

    def approved_conversions_sql(user_role: nil, **options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_approved(user_role).join("','")}')
          THEN COALESCE(conversions, 0) ELSE 0 END
        )
      SQL
    end

    def pending_conversions_sql(user_role: nil, **options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_pending(user_role).join("','")}') #{valid_status_sql(user_role, 'AND')}
          THEN COALESCE(conversions, 0) ELSE 0 END)
      SQL
    end

    def rejected_conversions_sql(user_role: nil, **options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_rejected.join("','")}') #{valid_status_sql(user_role, 'AND')}
          THEN COALESCE(conversions, 0) ELSE 0 END
        )
      SQL
    end

    def invalid_conversions_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('Invalid')
          THEN COALESCE(conversions, 0) ELSE 0 END
        )
      SQL
    end

    def confirmed_conversions_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('Approved', 'Adjusted', 'Rejected', 'Full Return')
          THEN COALESCE(conversions, 0) ELSE 0 END
        )
      SQL
    end

    def conversion_percentage_sql(**options)
      <<-SQL.squish
        (
          (
            #{captured_sql(**options)}
          ) / (CASE WHEN #{clicks_sql} = 0 THEN 1 ELSE #{clicks_sql} END)::float
        ) * 100
      SQL
    end

    def rejected_rate_sql(**options)
      <<-SQL.squish
        (
          (
            #{rejected_conversions_sql(**options)}
          ) /(CASE WHEN #{captured_sql(**options)} = 0 THEN 1 ELSE #{captured_sql(**options)} END)::float
        ) * 100
      SQL
    end

    def total_advertisers_registered_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN adv_uniq_id LIKE 'adv-%' AND conversions = 1 THEN 1 ELSE 0 END
        )
      SQL
    end

    def total_affiliates_registered_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN adv_uniq_id LIKE 'aff-%' AND conversions = 1 THEN 1 ELSE 0 END
        )
      SQL
    end

    def rejected_true_pay_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_rejected.join("','")}')
            AND offer_id IS NOT NULL AND order_id IS NULL
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('true_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def pending_true_pay_sql(user_role: nil, **options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_pending(user_role).join("','")}')
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('true_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def published_true_pay_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_publishable.join("','")}')
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('true_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def approved_true_pay_sql(user_role: nil, **options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_approved(user_role).join("','")}')
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('true_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def total_true_pay_sql(**options)
      <<-SQL.squish
        COALESCE(
          #{published_true_pay_sql(**options)} + #{pending_true_pay_sql(**options)}, 0
        )
      SQL
    end

    def approved_affiliate_pay_sql(user_role: nil, **options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_approved(user_role).join("','")}')
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('affiliate_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def pending_affiliate_pay_sql(user_role: nil, **options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_pending(user_role).join("','")}') #{valid_status_sql(user_role, 'AND')}
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('affiliate_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def total_affiliate_pay_sql(**options)
      <<-SQL.squish
        COALESCE(
          #{published_affiliate_pay_sql(**options)} + #{pending_affiliate_pay_sql(**options)}, 0
        )
      SQL
    end

    def rejected_affiliate_pay_sql(user_role: nil, **options)
      if user_role == :affiliate
        <<-SQL.squish
          SUM(
            CASE WHEN approval IN ('#{AffiliateStat.approvals_considered_rejected.join("','")}')
              AND (#{valid_status_sql})
              AND (conversions > 0 OR conversions < 0)
            THEN COALESCE(#{translate_forex_sql('affiliate_pay', **options)}, 0) ELSE 0 END
          )
        SQL
      else
        <<-SQL.squish
          SUM(
            CASE WHEN approval IN ('Rejected', 'Full Return')
              AND offer_id IS NOT NULL AND order_id IS NULL
              AND (conversions > 0 OR conversions < 0)
            THEN COALESCE(#{translate_forex_sql('affiliate_pay', **options)}, 0) ELSE 0 END
          )
        SQL
      end
    end

    def invalid_affiliate_pay_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('Invalid')
            AND offer_id IS NOT NULL AND order_id IS NULL
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('affiliate_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def invalid_affiliate_pay_with_order_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('Invalid')
            AND offer_id IS NOT NULL
            AND order_id IS NOT NULL
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('affiliate_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def margin_sql(**options)
      <<-SQL.squish
        (
          #{approved_true_pay_sql(**options)} - #{approved_affiliate_pay_sql(**options)}
        )
      SQL
    end

    def pending_margin_sql(**options)
      <<-SQL.squish
        (
          #{pending_true_pay_sql(**options)} - #{pending_affiliate_pay_sql(**options)}
        )
      SQL
    end

    def published_margin_sql(**options)
      <<-SQL.squish
        (
          #{published_true_pay_sql(**options)} - #{published_affiliate_pay_sql(**options)}
        )
      SQL
    end

    def total_margin_sql(**options)
      <<-SQL.squish
        (
          #{total_true_pay_sql(**options)} - #{total_affiliate_pay_sql(**options)}
        )
      SQL
    end

    def published_affiliate_pay_sql(**options)
      <<-SQL.squish
        SUM(
          CASE WHEN approval IN ('#{AffiliateStat.approvals_publishable.join("','")}')
            AND (conversions > 0 OR conversions < 0)
          THEN COALESCE(#{translate_forex_sql('affiliate_pay', **options)}, 0) ELSE 0 END
        )
      SQL
    end

    def order_total_sql(**options)
      <<-SQL.squish
        SUM(
          CASE
            WHEN approval IN ('#{AffiliateStat.approvals_considered_rejected.join("','")}') THEN 0
            ELSE COALESCE(#{translate_forex_sql('order_total', **options)}, 0)
          END
        )
      SQL
    end

    def true_pay_epc_sql(**options)
      <<-SQL.squish
        COALESCE(
          (
            #{total_true_pay_sql(**options)} /
            (
              CASE WHEN #{clicks_sql} = 0 THEN 1 ELSE #{clicks_sql} END
            )::float
          ), 0
        )
      SQL
    end

    def affiliate_pay_epc_sql(**options)
      <<-SQL.squish
        COALESCE(
          (
            #{total_affiliate_pay_sql(**options)} /
            (CASE WHEN #{clicks_sql} = 0 THEN 1 ELSE #{clicks_sql} END)::float
          ),
        0)
      SQL
    end

    def avg_true_pay_sql(**options)
      <<-SQL.squish
        COALESCE(
          (
            #{published_true_pay_sql(**options)} /
            (
              CASE WHEN #{published_conversions_sql(**options)} = 0
                THEN 1
                ELSE #{published_conversions_sql(**options)} END
            )
          ), 0
        )
      SQL
    end

    def avg_affiliate_pay_sql(**options)
      <<-SQL.squish
        COALESCE(
          (
            #{published_affiliate_pay_sql(**options)} /
            (
              CASE WHEN #{published_conversions_sql(**options)} = 0
                THEN 1
                ELSE #{published_conversions_sql(**options)} END
            )
          ), 0
        )
      SQL
    end

    def roas_sql(**options)
      <<-SQL.squish
        COALESCE(
          (
            #{order_total_sql(**options)} /
            (
              CASE WHEN #{total_true_pay_sql(**options)} = 0
                THEN 1
                ELSE #{total_true_pay_sql(**options)} END
            )
          ), 0
        )
      SQL
    end

    def translate_forex_sql(column, currency_code: Currency.default_code, **options)
      <<-SQL.squish
        (
          (1 / (json_extract_path_text(forex, COALESCE(original_currency, '#{Currency.platform_code}'))::float)) *
          (json_extract_path_text(forex, '#{currency_code}')::float) *
          #{column}
        )
      SQL
    end

    def zero_to_thirty_days_sql(time_zone: nil, user_role: nil)
      time_zone ||= TimeZone.current
      date_range = date_range_to_db(time_zone.local_range(:x_to_y_days_ago, x: 0, y: 30), time_zone)
      sanitize_sql([pending_conversions_within_range_sql(:zero_to_thirty_days, user_role: user_role), *date_range])
    end

    def thirty_to_sixty_days_sql(time_zone: nil, user_role: nil)
      time_zone ||= TimeZone.current
      date_range = date_range_to_db(time_zone.local_range(:x_to_y_days_ago, x: 31, y: 60), time_zone)
      sanitize_sql([pending_conversions_within_range_sql(:thirty_to_sixty_days, user_role: user_role), *date_range])
    end

    def sixty_to_one_eighty_days_sql(time_zone: nil, user_role: nil)
      time_zone ||= TimeZone.current
      date_range = date_range_to_db(time_zone.local_range(:x_to_y_days_ago, x: 61, y: 180), time_zone)
      sanitize_sql([pending_conversions_within_range_sql(:sixty_to_one_eighty_days, user_role: user_role), *date_range])
    end

    def one_eighty_and_older_days_sql(time_zone: nil, user_role: nil)
      time_zone ||= TimeZone.current
      date_range = date_range_to_db(time_zone.local_range(:x_to_y_days_ago, x: 181, y: 10_000), time_zone)
      sanitize_sql([pending_conversions_within_range_sql(:one_eighty_and_older_days, user_role: user_role),
        *date_range])
    end

    private

    def pending_conversions_within_range_sql(name, user_role: nil)
      <<-SQL.squish
        SUM(
          CASE
            WHEN stats.captured_at >= ? AND stats.captured_at <= ?
              AND approval IN ('#{AffiliateStat.approvals_considered_pending(user_role).join("','")}')
              AND offer_id IS NOT NULL
            THEN COALESCE(conversions, 0)
            ELSE 0
          END
        ) as #{name}
      SQL
    end

    def date_range_to_db(date_range, time_zone = nil)
      time_zone ||= TimeZone.current
      [
        time_zone.to_utc(date_range.first.beginning_of_day).to_s(:db),
        time_zone.to_utc(date_range.last.end_of_day).to_s(:db),
      ]
    end
  end
end
