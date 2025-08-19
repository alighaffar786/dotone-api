class Teams::NetworkOffer::FeaturedSerializer < Base::NetworkOfferSerializer
  attributes :id, :name, :status, :brand_image_large_url, :min_affiliate_pay, :max_affiliate_pay,
    :min_affiliate_share, :max_affiliate_share, :mixed_affiliate_pay, :brand_image_small_url
end
