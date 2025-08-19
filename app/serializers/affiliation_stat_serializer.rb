class AffiliationStatSerializer < ApplicationSerializer
  class NetworkOfferSerializer < Base::NetworkOfferSerializer
    attributes :id, :name, :status
  end

  attributes :offer_id, :applied, :total_applied, :clicks, :captured

  has_one :offer, serializer: NetworkOfferSerializer

  def offer
    instance_options.dig(:offers, object.offer_id) || object.offer
  end
end
