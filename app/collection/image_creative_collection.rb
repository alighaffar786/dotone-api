class ImageCreativeCollection < CreativeCollection
  private

  def ensure_filters
    super
    filter_by_not_suspended_offer
    filter_by_size if params[:size].present?
    filter_by_affiliate_offer_ids if params[:affiliate_offer_ids].present?
    filter_by_internals if params.key?(:internals)
  end

  def filter_by_size
    filter { @relation.where(size: params[:size]) }
  end

  def filter_by_not_suspended_offer
    filter do
      if affiliate_user?
        @relation = @relation
          .joins(:offer_variant)
          .where(offer_variants: { status: OfferVariant.status_considered_active })

        @relation = @relation.considered_non_rejected if params[:statuses].blank?
        @relation
      else
        @relation.joins(:offer_variant).merge(OfferVariant.not_suspended)
      end
    end
  end

  def filter_by_affiliate_offer_ids
    filter do
      @relation
        .joins(offer_variant: { offer: :affiliate_offers })
        .where(affiliate_offers: { id: params[:affiliate_offer_ids] })
    end
  end

  def filter_by_internals
    filter { @relation.where(internal: params[:internals]) }
  end

  def default_sorted
    sort do
      if affiliate?
        @relation.order(size: :asc)
      elsif affiliate_user?
        @relation.order_by_recent
      else
        @relation.order_by_status
      end
    end
  end
end
