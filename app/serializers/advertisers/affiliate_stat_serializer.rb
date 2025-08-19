class Advertisers::AffiliateStatSerializer < Base::AffiliateStatSerializer
  attributes :transaction_id, :copy_stat_id, :offer_id, :affiliate_id, :approval, :subid_1, :subid_2, :subid_3, :subid_4, :subid_5,
    :browser, :browser_version, :device_brand, :device_model, :device_type, :ip_address, :recorded_at, :captured_at,
    :published_at, :converted_at, :order_total, :true_pay, :true_conv_type, :adv_uniq_id, :isp, :step_name, :step_label,
    :order_number, :transaction_locked?

  has_one :copy_order, key: :order
  has_one :country
  has_one :offer, serializer: Advertisers::NetworkOffer::MiniSerializer
end
