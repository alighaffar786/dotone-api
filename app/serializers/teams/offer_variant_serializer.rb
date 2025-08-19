class Teams::OfferVariantSerializer < Base::OfferVariantSerializer
  attributes :id, :offer_id, :name, :is_default?, :destination_url, :description, :status, :deeplink_parameters,
    :can_config_url, :variant_type

  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer, if: :full_scope?
  has_one :network, serializer: Teams::Network::MiniSerializer, if: :full_scope?

  has_many :name_translations, if: :full_scope?
  has_many :description_translations, if: :full_scope?
  has_many :siblings

  def deeplink_parameters
    object.deeplink_parameters || []
  end

  def siblings
    instance_options[:siblings]&.dig(object.id)
  end
end
