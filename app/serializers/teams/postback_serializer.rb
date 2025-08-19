class Teams::PostbackSerializer < ApplicationSerializer
  class ConversionStatSerializer < ApplicationSerializer
    attributes :id, :conversions
  end

  attributes :id, :postback_type, :recorded_at, :raw_response, :raw_request, :affiliate_stat_id,
    :order_number, :order_id, :values, :ip_address

  has_one :conversion_stat, serializer: ConversionStatSerializer

  def order_id
    return if given_orders.blank?

    orders = given_orders[object.affiliate_stat_id]

    if orders.blank? && new_stat = given_stats[object.affiliate_stat_id]
      orders = given_orders[new_stat.id]
    end

    orders&.find { |order| order.order_number == object.order_number }&.id
  end

  def given_orders
    instance_options[:orders] || {}
  end

  def given_stats
    instance_options[:new_stats] || {}
  end
end
