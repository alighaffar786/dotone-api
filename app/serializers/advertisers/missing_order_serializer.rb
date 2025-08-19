class Advertisers::MissingOrderSerializer < Base::MissingOrderSerializer
  class NetworkOfferSerializer < Base::NetworkOfferSerializer
    attributes :id, :name, :payouts
  end

  attributes :id, :affiliate_id, :created_at, :confirming_at, :click_time, :question_type, :order_number, :order_time,
    :order_total, :payment_method, :device, :screenshot_cdn_url, :notes, :status, :status_reason, :considered_completed?,
    :true_pay, :transaction_status

  has_one :offer, serializer: NetworkOfferSerializer
  has_one :order
end
