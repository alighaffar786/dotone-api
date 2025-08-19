class Affiliates::TextCreativeSerializer < Base::TextCreativeSerializer
  attributes :id, :offer_id, :status, :creative_name, :original_price, :discount_price, :is_infinity_time, :active_date_start,
    :active_date_end, :locales, :status_reason, :button_text, :deal_scope, :coupon_code, :title, :content_1, :content_2,
    :image_url, :created_at, :ongoing?, :marketing_name, :published_at, :tracking_url

  conditional_attributes :approval_status, :reapply_note, :status_summary, :reject_reason, :min_affiliate_pay,
    :max_affiliate_pay, :min_affiliate_share, :max_affiliate_share, if: :full_scope_requested?

  has_many :categories, if: :full_scope_requested?

  has_one :currency
  has_one :offer, serializer: Affiliates::NetworkOffer::MiniSerializer, if: :full_scope_requested?
end
