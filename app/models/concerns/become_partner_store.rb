module BecomePartnerStore
  extend ActiveSupport::Concern
  include Relations::NetworkAssociated
  include Relations::OfferAssociated

  def mkt_site
    return if network.blank?

    this_offer = offer
    return if this_offer.blank?

    to_return = this_offer.mkt_site

    if to_return.blank?
      # Create new mkt site
      to_return = MktSite.create(
        domain: store_domain,
        network_id: network_id,
        offer_id: this_offer.id,
      )
    end

    to_return
  end

  def platform
    raise NotImplementedError
  end

  protected

  def browse_pixel_string
    site_id = mkt_site&.id

    return '' if site_id.blank?

    case platform
    when 'shopify'
      DotOne::ScriptGenerator.generate_shopify_pixel(site_id)
    when 'easystore'
      DotOne::ScriptGenerator.generate_easystore_pixel(site_id)
    else
      ''
    end
  end
end
