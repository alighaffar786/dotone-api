class Advertisers::StatPendingSerializer < ApplicationSerializer
  attributes :id, :offer_id, :zero_to_thirty_days, :thirty_to_sixty_days, :sixty_to_one_eighty_days, :one_eighty_and_older_days

  has_one :offer, serializer: Advertisers::NetworkOffer::MiniSerializer
end
