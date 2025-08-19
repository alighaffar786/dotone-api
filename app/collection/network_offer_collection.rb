class NetworkOfferCollection < OfferCollection
  private

  def ensure_filters
    super
    filter_non_suspended if affiliate? && params[:approval_statuses].blank?
    filter_by_category_group_ids if params[:category_group_ids].present?
    filter_by_media_restriction_ids if params[:media_restriction_ids].present?
    filter_by_group_tag_ids if params[:group_tag_ids].present?
    filter_by_affiliate_conv_types if params[:affiliate_conv_types].present?
    filter_by_true_conv_types if params[:true_conv_types].present?
    filter_by_deep_link if params.key?(:can_config_url)
    filter_by_product_apis if params.key?(:has_product_api)
    filter_by_translation if affiliate? && params[:locale].present? && !truthy?(params[:all_locale])
    filter_by_excluded_media_restriction_ids if params[:excluded_media_restriction_ids].present?
    filter_by_top_offer_category_id if params[:top_offer_category_id].present?
    filter_by_approval_methods if params[:approval_methods].present?
    filter_by_brand_image if params.key?(:brand_image)
    filter_by_translation_missing if params[:translation_missing].present?
    filter_by_attribution_types if params[:attribution_types].present?
    filter_by_track_devices if params[:track_devices].present?
    filter_by_conversion_points if params[:conversion_points].present?
    filter_by_mixed_affiliate_pay if params[:mixed_affiliate_pay].present?
    filter_by_ad_slot if truthy?(params[:for_ad_slot]) && affiliate?
    filter_by_mkt_sites if params[:with_mkt_site].present?
    filter_by_earning_meters if params[:earning_meters].present?
    filter_by_ad_links if truthy?(params[:ad_link])
  end

  def filter_by_approval_statuses
    filter do
      @relation.with_approval_statuses(ability, params[:approval_statuses])
    end
  end

  def filter_non_suspended
    filter do
      affiliate_offers = query_affiliate_offers(approval_statuses: AffiliateOffer.approval_status_suspended)
      @relation.where.not(id: affiliate_offers.select(:offer_id))
    end
  end

  def filter_by_category_group_ids
    filter { @relation.with_category_groups(params[:category_group_ids]) }
  end

  def filter_by_media_restriction_ids
    filter do
      @relation
        .left_outer_joins(:media_restrictions)
        .where(affiliate_tags: { id: params[:media_restriction_ids] })
        .distinct
    end
  end

  def filter_by_affiliate_conv_types
    filter { @relation.where(affiliate_conv_type: params[:affiliate_conv_types]) }
  end

  def filter_by_true_conv_types
    filter { @relation.where(true_conv_type: params[:true_conv_types]) }
  end

  def filter_by_deep_link
    filter do
      if truthy?(params[:can_config_url])
        @relation
          .joins(:default_offer_variant)
          .where(offer_variants: { can_config_url: true })
      elsif falsy?(params[:can_config_url])
        @relation
          .joins(:default_offer_variant)
          .where(offer_variants: { can_config_url: [false, nil] })
      else
        @relation
      end
    end
  end

  def filter_by_product_apis
    filter do
      if truthy?(params[:has_product_api])
        @relation.joins(:product_api)
      elsif falsy?(params[:has_product_api])
        @relation.where.not(id: @relation.joins(:product_api))
      else
        @relation
      end
    end
  end

  def filter_by_translation
    return @relation if params[:locale] == Language.platform_locale

    filter { @relation.translation_done([params[:locale]]) }
  end

  def filter_by_excluded_media_restriction_ids
    filter do
      @relation
        .left_outer_joins(:media_restrictions)
        .where.not(affiliate_tags: { id: params[:excluded_media_restriction_ids] })
        .distinct
    end
  end

  def filter_by_top_offer_category_id
    filter do
      @relation
        .left_outer_joins(:top_network_offer_categories)
        .where(affiliate_tags: { id: params[:top_offer_category_id] })
        .distinct
    end
  end

  def filter_by_approval_methods
    filter { @relation.where(approval_method: params[:approval_methods]) }
  end

  def filter_by_brand_image
    filter do
      if truthy?(params[:brand_image])
        @relation.joins(:brand_image)
      elsif falsy?(params[:brand_image])
        @relation.where.not(id: @relation.joins(:brand_image).select(:id))
      else
        @relation
      end
    end
  end

  def filter_by_translation_missing
    filter { @relation.translation_not_done(params[:translation_missing]) }
  end

  def filter_by_attribution_types
    filter { @relation.with_attribution_types(params[:attribution_types]) }
  end

  def filter_by_track_devices
    filter { @relation.with_track_devices(params[:track_devices]) }
  end

  def filter_by_conversion_points
    filter { @relation.with_conversion_points(params[:conversion_points]) }
  end

  def filter_by_mixed_affiliate_pay
    filter do
      @relation.where(mixed_affiliate_pay: truthy?(params[:mixed_affiliate_pay]))
    end
  end

  def filter_by_ad_slot
    filter do
      @relation
        .left_outer_joins(:offer_variants, :text_creatives)
        .where(offer_variants: { status: OfferVariant.status_considered_active })
        .where(need_approval: true)
        .or(@relation.where(text_creatives: TextCreative.accessible_by(ability).publishable.with_approval_statuses(ability, AffiliateOffer.approval_status_active)))
        .distinct
    end
  end

  def filter_by_mkt_sites
    filter { @relation.joins(:mkt_sites).distinct }
  end

  def filter_by_ad_links
    filter do
      if affiliate?
        offer_ids = query_affiliate_offers(approval_statuses: AffiliateOffer.approval_status_considered_approved).select(:offer_id)
        @relation.auto_approvable_offers.or(NetworkOffer.where(id: offer_ids))
      else
        @relation
      end
    end
  end

  def filter_by_earning_meters
    filter do
      @relation.where(earning_meter: params[:earning_meters])
    end
  end

  def default_sorted
    return @relation if params[:search].present?

    sort { @relation.order(published_date: :desc, id: :desc) }
  end

  def sort_by_cookie_days
    sort { @relation.order(cache_days_to_expire: sort_order) }
  end

  def sort_by_min_affiliate_pay
    sort do
      @relation
        .agg_affiliate_pay(ability&.user, currency_code)
        .order(min_affiliate_pay: sort_order)
    end
  end

  def sort_by_min_affiliate_share
    sort do
      @relation
        .agg_affiliate_pay(ability&.user, currency_code)
        .order(min_affiliate_share: sort_order)
    end
  end

  def sort_by_min_true_pay
    sort do
      @relation
        .agg_true_pay(currency_code)
        .order(min_true_pay: sort_order)
    end
  end

  def sort_by_min_true_share
    sort do
      @relation
        .agg_true_pay(currency_code)
        .order(min_true_share: sort_order)
    end
  end

  def sort_by_display_order
    sort do
      @relation
        .left_outer_joins(:top_network_offer_categories)
        .select('owner_has_tags.display_order')
        .order('owner_has_tags.display_order ASC')
    end
  end

  def sort_by_random
    sort { @relation.order('RAND()') }
  end

  def sort_by_offer_variant_status
    sort do
      @relation
        .left_outer_joins(:default_offer_variant)
        .order('offer_variants.status' => sort_order)
    end
  end

  def sort_by_approved_time
    sort do
      if affiliate?
        @relation
          .select(
            'offers.*',
            <<-SQL.squish
              CASE
                WHEN approval_method = '#{Offer.approval_method_payment_received}' THEN 'After Advertiser Payment'
                ELSE approved_time
              END AS affiliate_approved_time
            SQL
          )
          .order('ISNULL(approved_time)')
          .order(Arel.sql("FIELD(affiliate_approved_time, '#{NetworkOffer.approved_times.join('\',\'')}') #{sort_order}"))
          .order(approved_time_num_days: sort_order)
      else
        @relation
          .order('ISNULL(approved_time)')
          .order(Arel.sql("FIELD(offers.approved_time, '#{NetworkOffer.approved_times.join('\',\'')}') #{sort_order}"))
          .order(approved_time_num_days: sort_order)
      end
    end
  end

  def sort_by_approval_status
    @relation.select_approval_status(user).order(approval_status: sort_order)
  end
end
