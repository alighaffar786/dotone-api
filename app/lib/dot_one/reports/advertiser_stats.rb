class DotOne::Reports::AdvertiserStats
  include ActionView::Helpers::NumberHelper

  def initialize(network, report_month)
    @network = network
    @report_month = report_month
  end

  def build_report
    present_month_orders = orders_count(@report_month)
    last_month_orders = orders_count(@report_month - 1.month)
    banners_count = ImageCreative.includes(offer_variants: [offer: :network])
      .where(networks: { id: @network.id })
      .where(time_query('image_creatives.created_at', @network, @report_month)).count
    native_ad_count = TextCreative.includes(offer_variants: [offer: :network])
      .where(networks: { id: @network.id })
      .where(time_query('text_creatives.created_at', @network, @report_month)).count
    detail_views_count = @network.offers
      .joins(:offer_stats)
      .select('SUM(offer_stats.detail_view_count) as detail_views_count')
      .where(time_query('offer_stats.date', @network, @report_month)).last

    stats_result = Stat.select('SUM(impression) as impression_count, SUM(clicks) as clicks_count')
      .where(network_id: @network.id).recorded_at(@report_month)

    active_count = @network.offers.includes(:active_affiliates).map { |offer| offer.active_affiliates }.flatten.count

    {
      present_month_orders: postfix_converter(present_month_orders.to_i),
      last_month_orders: postfix_converter(last_month_orders.to_i),
      orders_difference: present_month_orders.to_i - last_month_orders.to_i,
      banners_count: postfix_converter(banners_count.to_i),
      native_ad_count: postfix_converter(native_ad_count.to_i),
      click_count: postfix_converter(stats_result[0].clicks_count.to_i),
      detail_views_count: postfix_converter(detail_views_count[:detail_views_count].to_i),
      active_affiliate_count: postfix_converter(active_count.to_i),
      impression_count: postfix_converter(stats_result[0].impression_count.to_i),
    }
  end

  def orders_count(time)
    Order.includes(:offer).joins(:offer)
      .with_networks(@network)
      .where(time_query('recorded_at', @network, time)).count
  end

  def time_query(field, network, time)
    "CONVERT_TZ('#{field}', '+00:00', '#{network.time_zone&.gmt_string}') <= '#{time.beginning_of_month}' AND
       CONVERT_TZ('#{field}', '+00:00', '#{network.time_zone&.gmt_string}') >= '#{time.end_of_month}' "
  end

  def postfix_converter(number)
    number_to_human(number).gsub(' Thousand', 'K')
      .gsub(' Million', 'M')
      .gsub(' Billion', 'B')
      .gsub(' Trillion', 'T')
      .gsub(' Quadrillion', 'Q')
  end
end
