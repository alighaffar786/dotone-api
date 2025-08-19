class Api::Client::Advertisers::NetworkOffersController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource except: :search

  def index
    @network_offers = paginate(query_index)
    respond_with_pagination(
      @network_offers,
      pending_conversion_counts: pending_conversion_counts,
      active_image_creative_counts: active_image_creative_counts,
      active_text_creative_counts: active_text_creative_counts,
      missing_order_counts: missing_order_counts,
      active_affiliate_counts: active_affiliate_counts,
    )
  end

  def search
    authorize! :read, NetworkOffer
    @network_offers = query_search
    respond_with @network_offers, each_serializer: Advertisers::NetworkOffer::SearchSerializer, **search_params
  end

  private

  def query_index
    NetworkOfferCollection.new(@network_offers, params)
      .collect
      .preload(
        :aff_hash, :offer_cap, :categories, :countries, :offer_stats_last_month, :brand_background_translations,
        :owner_has_tags, :media_restrictions, :name_translations, :short_description_translations,
        :product_description_translations, :target_audience_translations, :suggested_media_translations,
        :other_info_translations, :brand_image_medium, :product_api,
        ordered_conversion_steps: [:true_currency, :label_translations, :active_pay_schedule],
        offer_variants: :name_translations,
        default_offer_variant: :name_translations
      )
      .joins(
        <<-SQL.squish
          INNER JOIN (SELECT * FROM offer_variants WHERE offer_variants.is_default = 1) AS default_offer_variants
          ON default_offer_variants.offer_id = offers.id
        SQL
      )
      .reorder(Arel.sql("FIELD(default_offer_variants.status, 'Active Public', 'Active Private', 'Paused', 'Suspended'), published_date DESC"))
  end

  def query_search
    collection = NetworkOfferCollection.new(current_ability, params, **current_options).search
    collection = collection.preload(:default_offer_variant, active_offer_variants: :name_translations) if search_params[:offer_variants]
    collection = collection.preload(:mkt_site) if search_params[:with_mkt_site]
    collection
  end

  def network_offer_ids
    @network_offer_ids ||= @network_offers.map(&:id)
  end

  def pending_conversion_counts
    @pending_conversion_counts ||= AffiliateStatCapturedAt
      .accessible_by(current_ability)
      .with_offers(network_offer_ids)
      .where(approval: AffiliateStat.approvals_considered_pending(:network))
      .where('captured_at >= ?', 6.months.ago)
      .group(:offer_id)
      .count
  end

  def active_image_creative_counts
    @active_image_creative_counts ||= ImageCreative
      .accessible_by(current_ability)
      .considered_active
      .with_offers(network_offer_ids)
      .with_locales(current_locale)
      .group(:offer_id)
      .count
  end

  def active_text_creative_counts
    @active_text_creative_counts ||= TextCreative
      .accessible_by(current_ability)
      .considered_active
      .with_offers(network_offer_ids)
      .with_locales(current_locale)
      .group(:offer_id)
      .count
  end

  def missing_order_counts
    @missing_order_counts ||= MissingOrder
      .confirming
      .accessible_by(current_ability)
      .where(offer_id: network_offer_ids)
      .group(:offer_id)
      .count
  end

  def active_affiliate_counts
    @active_affiliate_counts ||= NetworkOffer
      .joins(:active_affiliates)
      .where(id: network_offer_ids)
      .group(:offer_id)
      .count
  end

  def search_params
    params.permit(:offer_variants, :with_mkt_site).to_h.symbolize_keys
  end
end
