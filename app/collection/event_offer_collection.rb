class EventOfferCollection < OfferCollection
  private

  [:applied_by, :selection_by, :submission_by, :evaluation_by, :published_by, :popularity, :value].each do |column|
    define_method "sort_by_event_info_#{column}" do
      sort do
        @relation.select("offers.*, event_infos.#{column}").order("event_infos.#{column} #{sort_order}")
      end
    end
  end

  def ensure_filters
    super
    filter { @relation.joins(:event_info) }
    filter_by_privacy if params.key?(:private) && (params[:include_private].blank? || falsy?(params[:include_private]))
    filter_by_media_category_ids if params[:media_category_ids].present?
    filter_by_event_media_category_ids if params[:event_media_category_ids].present?
    filter_by_personalized if truthy?(params[:personalized])
    filter_by_event_types if params[:event_types].present?
    filter_by_availability_types if params[:availability_types].present?
    filter_by_fulfillment_types if params[:fulfillment_types].present?
    filter_applied if truthy?(params[:applied])
  end

  def filter_applied
    filter do
      filter_by_approval_statuses(AffiliateOffer.event_approval_considered_applied) if params[:approval_statuses].blank?
      affiliate_offers_pending = query_event_affiliate_offers(
        offer_variant_statuses: OfferVariant.status_considered_active_fulfilled,
        approval_statuses: AffiliateOffer.approval_statuses_considered_pending,
      )
      affiliate_offers_selected = query_event_affiliate_offers(
        offer_variant_statuses: OfferVariant.status_considered_positive,
        approval_statuses: AffiliateOffer.event_approval_statuses - AffiliateOffer.approval_statuses_considered_pending,
      )
      @relation
        .where(id: affiliate_offers_pending.select(:offer_id))
        .or(@relation.where(id: affiliate_offers_selected.select(:offer_id)))
    end
  end

  def filter_by_privacy
    filter do
      if truthy?(params[:private])
        @relation.private_events
      else
        @relation.public_events
      end
    end
  end

  def filter_by_approval_statuses(*args)
    filter do
      @relation.with_approval_statuses(ability, (params[:approval_statuses] || args))
    end
  end

  def filter_by_media_category_ids
    filter do
      @relation
        .joins(event_info: :affiliate_tags)
        .where(affiliate_tags: { id: params[:media_category_ids] })
        .distinct
    end
  end

  def filter_by_event_media_category_ids
    filter do
      @relation
        .joins(event_info: :event_media_category)
        .where(affiliate_tags: { id: params[:event_media_category_ids] })
    end
  end

  def filter_by_event_types
    filter do
      @relation.where(event_infos: { event_type: params[:event_types] })
    end
  end

  def filter_by_availability_types
    filter do
      @relation.where(event_infos: { availability_type: params[:availability_types] })
    end
  end

  def filter_by_fulfillment_types
    filter do
      @relation.where(event_infos: { fulfillment_type: params[:fulfillment_types] })
    end
  end

  def default_sorted
    sort_by_offer_variant_status
  end

  def sort_by_total_value
    sort do
      @relation
        .select_forex_total(currency_code)
        .order(forex_total_value: sort_order)
    end
  end

  def sort_by_affiliate_pay
    sort do
      @relation
        .select_forex_total(currency_code)
        .order(forex_affiliate_pay: sort_order)
    end
  end

  def sort_by_true_pay
    sort do
      @relation
        .select_forex_total(currency_code)
        .order(forex_true_pay: sort_order)
    end
  end

  def sort_by_request_count
    sort do
      @relation
        .joins(:event_info)
        .agg_request_count
        .order(request_count: sort_order)
        .order("event_infos.quota #{sort_order}")
    end
  end

  def sort_by_offer_variant_status
    sort { @relation.order_by_status_priority(sort_order) }
  end

  def personalized_media_category_ids
    SiteInfo.accessible_by(ability)
      .distinct
      .select('affiliate_tags.id')
      .joins(:media_category)
      .map(&:id)
  end

  def filter_by_personalized
    return unless affiliate?

    filter do
      @relation
        .joins(event_info: :media_category)
        .where(affiliate_tags: { id: personalized_media_category_ids })
        .distinct
    end
  end
end
