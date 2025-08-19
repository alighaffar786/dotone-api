class Teams::MissingOrderSerializer < Base::MissingOrderSerializer
  attributes :id, :order_id, :created_at, :confirming_at, :click_time, :question_type, :order_number, :order_time,
    :order_total, :payment_method, :device, :screenshot_cdn_url, :notes, :status, :status_reason,
    :true_pay, :transaction_status, :rejecter, :offer_id, :affiliate_id, :status_summary, :affiliate_stat_id

  original_attributes :order_total, :true_pay

  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer
  has_one :affiliate, serializer: Teams::Affiliate::MiniSerializer
  has_one :currency

  def order_id
    object.found_order_id
  end

  def affiliate_stat_id
    object.order&.affiliate_stat_id
  end
end
