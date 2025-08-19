class TextCreativeCollection < CreativeCollection
  private

  def ensure_filters
    super
    filter_by_time_period if params[:time_period].present?
    filter_by_category_ids if params[:category_ids].present?
    filter_by_category_group_ids if params[:category_group_ids].present?
    filter_by_approval_statuses if params[:approval_statuses].present?
    filter_non_suspended if affiliate? && truthy?(params[:exclude_suspended])
    filter_by_network_ids if params[:network_ids].present?
    filter_by_has_coupons if truthy?(params[:has_coupons]) || falsy?(params[:has_coupons])
  end

  def filter_by_time_period
    filter do
      case params[:time_period]
      when 'ongoing'
        @relation.publishable
      when 'upcoming'
        @relation.upcoming
      else
        @relation
      end
    end
  end

  def filter_by_category_ids
    filter do
      @relation
        .left_outer_joins(:categories)
        .where(categories: { id: params[:category_ids] })
    end
  end

  def filter_by_category_group_ids
    filter { @relation.with_category_groups(params[:category_group_ids]) }
  end

  def filter_by_approval_statuses
    filter do
      @relation.with_approval_statuses(ability, params[:approval_statuses])
    end
  end

  def filter_non_suspended
    filter do
      affiliate_offers = AffiliateOffer.accessible_by(ability)
        .where(approval_status: AffiliateOffer.approval_status_suspended)
      @relation
        .joins(:offer)
        .where.not(offers: { id: affiliate_offers.select(:offer_id) })
    end
  end

  def filter_by_network_ids
    filter do
      @relation.joins(:network).where(networks: { id: params[:network_ids] })
    end
  end

  def filter_by_has_coupons
    filter do
      if truthy?(params[:has_coupons])
        @relation.where.not(coupon_code: [nil, ''])
      else
        @relation.where(coupon_code: [nil, ''])
      end
    end
  end

  def default_sorted
    sort do
      @relation.order_by_status.order('ISNULL(active_date_start), active_date_start ASC, text_creatives.created_at ASC')
    end
  end
end
