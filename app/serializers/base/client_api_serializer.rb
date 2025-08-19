class Base::ClientApiSerializer < ApplicationSerializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Affiliate'
      Teams::Affiliate::MiniSerializer
    when 'Network'
      Teams::Network::MiniSerializer
    when 'NetworkOffer'
      Teams::NetworkOffer::MiniSerializer
    else
      super
    end
  end
end
