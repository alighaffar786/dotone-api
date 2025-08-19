class Affiliates::Product::SearchSerializer < Base::ProductSerializer
  attributes :id, :title, :offer_id, :image, :price, :is_promotion
end
