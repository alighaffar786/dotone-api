  # frozen_string_literal: true

class MktSite::CodeSerializer < ApplicationSerializer
  class ConversionStepSerializer < Base::ConversionStepSerializer
    attributes :id, :label, :conversion_pixel, :conversion_pixel_async

    def conversion_pixel
      object.offer.mkt_site.site_code(conversions: true, order: true, step_name: object.name, for_gtm: instance_options[:for_gtm])
    end

    def conversion_pixel_async
      object.offer.mkt_site.site_code(conversions: true, order: true, step_name: object.name, for_gtm: instance_options[:for_gtm], async: true)
    end
  end

  class NetworkOfferSerializer < Base::NetworkOfferSerializer
    attributes :id, :name

    has_many :conversion_steps, serializer: ConversionStepSerializer
  end

  class NetworkSerializer < Base::NetworkSerializer
    attributes :id, :name
  end

  attributes :id, :offer_id, :network_id, :browse_pixel, :browse_pixel_async, :for_gtm
  attribute :gtm_script, if: :for_gtm

  has_one :offer, serializer: NetworkOfferSerializer
  has_one :network, serializer: NetworkSerializer

  def network
    object.network || object.offer.network
  end

  def browse_pixel
    object.site_code
  end

  def browse_pixel_async
    object.site_code(async: true)
  end

  def gtm_script
    DotOne::ScriptGenerator.generate_gtm_script
  end

  def for_gtm
    instance_options[:for_gtm]
  end
end
