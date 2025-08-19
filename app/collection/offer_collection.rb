class OfferCollection < BaseCollection
  def search
    collect.preload_translations(:name)
  end

  protected

  def ensure_filters
    super
    filter_by_approval_statuses if params[:approval_statuses].present?
    fitler_by_network_ids if params[:network_ids].present?
    filter_by_category_ids if params[:category_ids].present?
    filter_by_country_ids if params[:country_ids].present?
    filter_by_country_codes if params[:country_codes].present?
    filter_by_variant_statuses if params[:offer_variant_statuses].present?
    filter_by_active if truthy?(params[:active])
  end

  def filter_by_approval_statuses
    raise NotImplementedError
  end

  def fitler_by_network_ids
    filter { @relation.where(network_id: params[:network_ids]) }
  end

  def filter_by_category_ids
    filter do
      @relation
        .left_outer_joins(:categories)
        .where(categories: { id: params[:category_ids] })
        .distinct
    end
  end

  def filter_by_country_ids
    filter do
      @relation.with_countries(params[:country_ids])
    end
  end

  def filter_by_country_codes
    filter do
      @relation
        .left_outer_joins(:countries)
        .where(countries: { iso_2_country_code: params[:country_codes] })
        .distinct
    end
  end

  def filter_by_variant_statuses
    filter do
      @relation
        .left_outer_joins(:offer_variants)
        .where(offer_variants: { status: params[:offer_variant_statuses] })
        .distinct
    end
  end

  def query_affiliate_offers(params = {})
    affiliate_offers = ability if affiliate?
    affiliate_offers ||= affiliate_ability || AffiliateOffer
    AffiliateOfferCollection.new(affiliate_offers, params).collect
  end

  def query_event_affiliate_offers(params = {})
    affiliate_offers = ability if affiliate?
    affiliate_offers ||= affiliate_ability || AffiliateOffer
    EventAffiliateOfferCollection.new(affiliate_offers, params).collect
  end

  def filter_by_active
    filter do
      params[:offer_variant_statuses] = OfferVariant.status_considered_active
      filter_by_variant_statuses
    end
  end
end
