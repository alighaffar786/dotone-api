class Advertisers::EasyStoreSetupSerializer < ApplicationSerializer
  attributes :id, :store_name, :store_title, :store_domain, :email, :deployed?

  has_one :offer, serializer: Advertisers::NetworkOffer::MiniSerializer
end
