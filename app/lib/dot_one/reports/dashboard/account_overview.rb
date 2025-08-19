# frozen_string_literal: true

module DotOne::Reports::Dashboard
  class AccountOverview < Base
    def generate
      super do
        {
          total_orders: format_data(orders),
          offer_clicks: format_data(clicks),
          offer_application: format_data(application),
          unique_offer_view: format_data(unique_offer_view),
        }
      end
    end

    private

    def self.approvals
      [
        AffiliateStat.approval_pending,
        AffiliateStat.approval_approved,
        AffiliateStat.approval_invalid,
        AffiliateStat.approval_adjusted,
      ]
    end

    def orders
      @orders ||= stats
        .where(approval: self.class.approvals)
        .where("captured_at <= '#{end_of_today}' and captured_at >= '#{days_ago_in_utc(16)}'")
        .where.not(conversions: nil)
        .group("DATE(convert_timezone('GMT#{time_zone.gmt_string}', captured_at))")
        .sum(:conversions)
        .map { |k, v| [k.to_s, v.to_i] }
        .to_h
    end

    def clicks
      @clicks ||= stats
        .where("recorded_at <= '#{end_of_today}' and recorded_at >= '#{days_ago_in_utc(16)}'")
        .group("DATE(convert_timezone('GMT#{time_zone.gmt_string}', recorded_at))")
        .sum(:clicks)
        .map { |k, v| [k.to_s, v.to_i] }
        .to_h
    end

    def application
      @application ||= AffiliateOffer.where(offer_id: offer_ids)
        .where("created_at <= '#{end_of_today}' and created_at >= '#{days_ago_in_utc(16)}'")
        .group("DATE(CONVERT_TZ(created_at, '+00:00', '#{time_zone.gmt_string}'))")
        .count
        .map { |k, v| [k.to_s, v.to_i] }
        .to_h
    end

    def unique_offer_view
      @unique_offer_view ||= OfferStat.where(offer_id: offer_ids)
        .where("date <= '#{end_of_today}' and date >= '#{days_ago_in_utc(16)}'")
        .group("DATE(CONVERT_TZ(date, '+00:00', '#{time_zone.gmt_string}'))")
        .sum(:detail_view_count)
        .map { |k, v| [k.to_s, v.to_i] }
        .to_h
    end

    def format_data(data)
      today = time_zone.from_utc(Time.now.utc).to_date

      this_week_data = format_data_in_range(data, days_ago(7), today)
      last_week_data = format_data_in_range(data, days_ago(15), days_ago(8))
      this_week_total = get_total_in_range(this_week_data, days_ago(7), today)
      last_week_total = get_total_in_range(last_week_data, days_ago(15), days_ago(8))

      {
        this_week: this_week_data,
        last_week: last_week_data,
        percentage: calc_percentage_and_direction(last_week_total, this_week_total),
      }
    end
  end
end
