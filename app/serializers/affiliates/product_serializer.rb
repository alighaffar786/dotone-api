class Affiliates::ProductSerializer < Base::ProductSerializer
  attributes :id, :image, :title, :price, :retail_price, :sale_price, :is_promotion, :commissions,
    :description_1, :descriptions, :product_url

  has_one :offer, serializer: Affiliates::NetworkOffer::MiniSerializer

  def offer
    offers_map ? offers_map[object.offer_id] : object.offer
  end

  def commissions
    offer&.commission_details(affiliate: current_user, currency_code: currency_code)
  end

  private

  def offers_map
    instance_options[:offers_map]
  end
end
