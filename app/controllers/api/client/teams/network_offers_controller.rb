class Api::Client::Teams::NetworkOffersController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: [:search, :recent, :conversion_so_far]
  load_resource only: :conversion_so_far

  def index
    @network_offers = paginate(query_index)
    respond_with_pagination(
      @network_offers,
      each_serializer: Teams::NetworkOffer::IndexSerializer,
      click_volumes: query_click_volumes,
      epcs: query_epcs,
    ) do |current|
      format_index(current)
    end
  end

  def create
    if @network_offer.save
      respond_with @network_offer
    else
      respond_with @network_offer, status: :unprocessable_entity
    end
  end

  def show
    respond_with @network_offer, serializer: Teams::NetworkOfferSerializer,
      meta: { t_columns: NetworkOffer.dynamic_translatable_attribute_types }
  end

  def update
    if @network_offer.update(network_offer_params)
      respond_with @network_offer, serializer: Teams::NetworkOfferSerializer
    else
      respond_with @network_offer, status: :unprocessable_entity
    end
  end

  def recent
    authorize! :read, NetworkOffer
    @network_offers = paginate(query_index)
    respond_with_pagination @network_offers, each_serializer: Teams::NetworkOffer::RecentSerializer do |current|
      format_recent(current)
    end
  end

  def search
    authorize! :read, NetworkOffer
    @network_offers = query_search
    respond_with @network_offers, each_serializer: Teams::NetworkOffer::SearchSerializer, **search_params
  end

  def download
    @download = build_download(query_index, current_columns)
    authorize! :create, @download
    authorize! :download, NetworkOffer

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def duplicate
    @copy = DotOne::Copier::NetworkOffer.new(@network_offer, current_user).copy

    if @copy.persisted?
      respond_with @copy
    else
      respond_with @copy, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = NetworkOfferCollection.new(current_ability, params, **current_options).collect
    collection = collection.reorder(id: :desc) if params[:sort_field].blank?
    collection
  end

  def query_search
    NetworkOfferCollection.new(current_ability, params, **current_options).search
  end

  def format_index(current)
    collection = current
      .agg_request_count
      .agg_true_pay(current_currency_code)
      .agg_affiliate_pay(current_user, current_currency_code)
      .preload_translations(:name, :short_description)
      .preload(
        :brand_image_small, :brand_image, :categories, :countries, :aff_hash, :media_restrictions,
        :offer_stats_last_month, :product_api, :group_tags, :default_offer_variant, default_conversion_step:
        :true_currency, admin_logs: [:agent, :crm_info, :crm_infos]
      )

    collection = collection.preload(:network) if can?(:read, Network)

    collection
  end

  def format_recent(current)
    current
      .agg_true_pay(current_currency_code)
      .agg_affiliate_pay(current_user, current_currency_code)
      .preload_translations(:name, :product_description, :approval_message)
      .preload(
        :brand_image_small, :categories, :countries, :media_restrictions,
        :network, :default_offer_variant, default_conversion_step: :label_translations,
      )
  end

  def query_click_volumes
    report = DotOne::Reports::OfferClickVolume.new(current_options)
    report.generate
  end

  def query_epcs
    report = DotOne::Reports::OfferClickVolume.new(current_options)
    report.generate_epc
  end

  def network_offer_params
    assign_local_time_params(network_offer: [:expired_at, :published_date])
    assign_forex_value_params(network_offer: [:custom_epc])

    params.require(:network_offer)
      .permit(
        :conversion_point, :network_id, :name, :short_description, :preview_url, :destination_url, :no_expiration,
        :will_notify_24_hour_paused, :will_notify_48_hour_paused, :redirect_url, :client_offer_name, :client_uniq_id,
        :brand_background, :product_description, :other_info, :target_audience, :suggested_media, :keywords,
        :earning_meter, :offer_name, :package_name, :manager_insight,
        :approval_method, :captured_time, :captured_time_num_days, :published_time, :published_time_num_days,
        :approved_time, :approved_time_num_days, :enforce_uniq_ip, :skip_order_api, :attribution_type,
        :approval_message, :click_geo_filter, :meta_refresh_redirect, :need_approval, :placement_needed,
        :custom_approval_message, :do_not_reformat_deeplink_url, :use_direct_advertiser_url,
        :brand_image_url, :brand_image_small_url, :brand_image_medium_url, :brand_image_large_url, :click_pixels,
        :min_conv_rate, :max_conv_rate, :min_epc, :max_epc, :mixed_affiliate_pay,
        hash_tokens: [:key, :value], forex_custom_epc: [], category_ids: [], group_tag_ids: [], expired_at_local: [],
        published_date_local: [], top_traffic_source_ids: [], whitelisted_destination_urls: [],
        track_device: [], media_restriction_ids: [], country_ids: [], deeplink_modifier: [:original, :replacement],
        default_offer_variant_attributes: [
          :id, :destination_url, :status, :should_notify_status_change, :can_config_url,
          offer_cap_attributes: [:id, :cap_type, :number, :earliest_at_local],
          deeplink_parameters: [:key, :value]
        ],
        translations_attributes: [:id, :locale, :field, :content]
      )
  end

  def search_params
    params.permit(:categories, :offer_variants).to_h.symbolize_keys
  end
end
