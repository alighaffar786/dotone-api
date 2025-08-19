class Affiliates::MissingOrderSerializer < Base::MissingOrderSerializer
  attributes :id, :affiliate_id, :created_at, :confirming_at, :click_time, :question_type, :order_number, :order_time,
    :order_total, :payment_method, :device, :screenshot_cdn_url, :notes, :status, :status_reason, :transaction_status

  has_one :offer, serializer: Affiliates::NetworkOffer::MiniSerializer
  has_one :order
end
