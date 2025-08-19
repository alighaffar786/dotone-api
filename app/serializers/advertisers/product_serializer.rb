class Advertisers::ProductSerializer < Base::ProductSerializer
  attributes :id, :image, :title, :price, :retail_price, :sale_price, :is_promotion, :descriptions

  has_one :offer, serializer: Advertisers::NetworkOffer::MiniSerializer
end
