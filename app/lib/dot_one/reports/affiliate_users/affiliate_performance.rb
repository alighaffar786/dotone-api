module DotOne::Reports::AffiliateUsers
  class AffiliatePerformance < BasePerformance
    def week_data
      {
        new_member: members_count,
        new_member_logins: members_login_count,
        member_login_ratio: members_login_ratio,
        total_members: total_members,
        total_member_logins: total_member_logins,
        total_member_logins_ratio: total_member_logins_ratio,
        total_active_members: active_total_members,
        active_member_ratio: active_member_ratio,
        member_with_transaction: member_with_transaction,
        member_with_all_week_transaction: member_with_all_week_transaction,
        conversion_rate: conversion_rate,
        member_with_offers: member_with_offers,
      }
    end

    private

    def members
      Affiliate.merge(query_by_date_range(Affiliate, 'created_at'))
    end

    def members_count
      members.count
    end

    def members_login_count
      members.where.not(last_request_at: nil).count
    end

    def members_login_ratio
      ((members_login_count / members_count) * 100).round(2)
    rescue StandardError
      0
    end

    def total_members
      start_at = date_range_in_utc.first - 1.year
      Affiliate.merge(query_by_date_range(Affiliate, 'last_request_at', start_at)).count
    end

    def total_member_logins
      Affiliate.merge(query_by_date_range(Affiliate, 'last_request_at')).count
    end

    def total_member_logins_ratio
      ((total_member_logins.to_f / total_members) * 100).round(2)
    rescue StandardError
      0
    end

    def active_total_members
      Stat.merge(query_by_date_range(Stat, 'recorded_at'))
        .group(:affiliate_id)
        .having('sum(clicks) > 10')
        .pluck('affiliate_id', 'sum(clicks)').count
    end

    def active_member_ratio
      ((active_total_members / total_members) * 100).round(2)
    rescue StandardError
      0
    end

    def member_with_transaction
      Stat.merge(query_by_date_range(Stat, 'captured_at'))
        .pluck(:affiliate_id)
        .uniq.count
    end

    def member_with_all_week_transaction
      @data ||= Stat.find_by_sql(member_with_all_week_transaction_query).inject(0) do |member_count, stat|
        member_count += 1 if stat.week_1 * stat.week_2 * stat.week_3 * stat.week_4 > 0
        member_count
      end
    end

    def member_with_all_week_transaction_query
      time_zone = TimeZone.platform
      weeks_in_time = @weeks.map do |date_range|
        [
          time_zone.to_utc(date_range.first.beginning_of_day).to_s(:db),
          time_zone.to_utc(date_range.last.end_of_day).to_s(:db),
        ]
      end

      <<-SQL.squish
        SELECT affiliate_id,
          SUM(case when #{redshift_time_query('captured_at', weeks_in_time.last.first, weeks_in_time.last.last)} then 1 else 0 end) AS week_1,
          SUM(case when #{redshift_time_query('captured_at', weeks_in_time.third.first, weeks_in_time.third.last)} then 1 else 0 end) AS week_2,
          SUM(case when #{redshift_time_query('captured_at', weeks_in_time.second.first, weeks_in_time.second.last)} then 1 else 0 end) AS week_3,
          SUM(case when #{redshift_time_query('captured_at', weeks_in_time.first.first, weeks_in_time.first.last)} then 1 else 0 end) AS week_4
        FROM stats
        WHERE #{redshift_time_query('captured_at', weeks_in_time.last.first, weeks_in_time.first.last)} AND conversions >= 1
        GROUP BY affiliate_id
      SQL
    end

    def conversion_rate
      ((member_with_transaction / active_total_members) * 100).round(2)
    rescue StandardError
      0
    end

    def member_with_offers
      Affiliate.joins(:offers)
        .merge(query_by_date_range(Offer, 'created_at'))
        .count
    end

    def redshift_time_query(field, start_at, end_at)
      "#{field} BETWEEN '#{start_at}' AND '#{end_at}'"
    end
  end
end
