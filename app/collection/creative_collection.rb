class CreativeCollection < BaseCollection
  protected

  def ensure_filters
    super
    filter_distinct
    filter_by_statuses if params[:statuses].present?
    filter_by_offer_ids if params[:offer_ids].present?
    filter_by_offer_variant_ids if params[:offer_variant_ids].present?
    filter_by_locales if params[:creative_locales].present? || params[:locale].present?
    filter_by_network_ids if params[:network_ids].present?
    filter_by_offer_variant_statuses if params[:offer_variant_statuses].present?
    filter_by_with_active_affiliate_offers if affiliate? && truthy?(params[:with_active_affiliate_offers])
  end

  def filter_by_statuses
    filter { @relation.where(status: params[:statuses]) }
  end

  def filter_by_offer_ids
    filter do
      @relation
        .joins(:offer_variant)
        .where(offer_variants: { offer_id: params[:offer_ids] })
    end
  end

  def filter_by_offer_variant_ids
    filter do
      @relation
        .joins(:offer_variant)
        .where(offer_variants: { id: params[:offer_variant_ids] })
    end
  end

  def filter_by_locales
    filter do
      if params[:creative_locales].present?
        @relation.with_locales(params[:creative_locales], exact: true)
      elsif !affiliate_user?
        @relation.with_locales(params[:locale])
      else
        @relation
      end
    end
  end

  def filter_by_network_ids
    filter do
      @relation.joins(:network).where(networks: { id: params[:network_ids] })
    end
  end

  def filter_by_offer_variant_statuses
    filter do
      @relation
        .joins(:offer_variant)
        .where(offer_variants: { status: params[:offer_variant_statuses] })
    end
  end

  def filter_by_with_active_affiliate_offers
    filter do
      affiliate_offers = AffiliateOffer.accessible_by(ability).active

      @relation
        .joins(:offer)
        .where(offers: { id: affiliate_offers.select(:offer_id) })
    end
  end
end
