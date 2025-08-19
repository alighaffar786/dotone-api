class Teams::EasyStoreSetupSerializer < Base::EventInfoSerializer
  attributes :id, :store_name, :store_title, :store_domain, :email, :deployed?

  has_one :network, serializer: Teams::Network::MiniSerializer
  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer
end
