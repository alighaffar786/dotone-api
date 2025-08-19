class Api::Client::Teams::AffiliateOffersController < Api::Client::Teams::BaseController
  include DotOne::Track

  load_and_authorize_resource

  def index
    @affiliate_offers = paginate(query_index)
    respond_with_pagination @affiliate_offers, total_cap_allocated: query_total_cap_allocated
  end

  def create
    if @affiliate_offer.save
      respond_with @affiliate_offer
    else
      respond_with @affiliate_offer, status: :unprocessable_entity
    end
  end

  def update
    if @affiliate_offer.update(affiliate_offer_params)
      respond_with @affiliate_offer
    else
      respond_with @affiliate_offer, status: :unprocessable_entity
    end
  end

  def bulk_update
    authorize! :update, AffiliateOffer
    start_bulk_update_job(
      AffiliateOffers::BulkUpdateJob,
      affiliate_offer_params,
    )
    head :ok
  end

  def generate_url
    @collection = ClickUrlSet.new(tracking_params).generate
    respond_with @collection
  end

  private

  def query_index
    collection = AffiliateOfferCollection.new(@affiliate_offers, params, **current_options).collect
    collection = collection.preload(
      :default_offer_variant, :aff_hash, :cap_time_zone_item,
      affiliate: [:affiliate_users, :recruiter], offer: [:group_tags, :name_translations]
    )

    if can?(:read, Affiliate)
      collection = collection.preload(
        :offer_cap, :step_pixels, default_conversion_step: [:true_currency, :available_pay_schedule],
        step_prices: [:true_currency, :available_pay_schedule],
        affiliate: [:group_tags, :affiliate_application]
      )
    end

    collection
  end

  def query_total_cap_allocated
    AffiliateOffer
      .where(offer_id: @affiliate_offers.map(&:offer_id))
      .group(:offer_id)
      .sum(:cap_size)
  end

  def affiliate_offer_params
    if params[:affiliate_offer][:bulk_step_price_attributes].present?
      assign_forex_value_params([:custom_amount], params[:affiliate_offer][:bulk_step_price_attributes])
    end

    params[:affiliate_offer][:step_prices_attributes].to_a.each do |step_price_params|
      step_price_params[:pay_schedules_attributes].to_a.each do |pay_schedule_params|
        assign_local_time_params([:starts_at, :ends_at], pay_schedule_params)
      end
    end

    assign_local_time_params(affiliate_offer: [:cap_earliest_at])

    params.require(:affiliate_offer).permit(
      :approval_status, :status_summary, :status_reason, :is_custom_commission, :bulk_conversion_step_id,
      :conversion_pixel_html, :conversion_pixel_s2s, :cap_type, :cap_size, :cap_redirect, :cap_notification_email,
      :cap_time_zone, :pixel_suppress_rate, :affiliate_id, :offer_id, cap_earliest_at_local: [],
      bulk_step_price_attributes: [:custom_share, forex_custom_amount: []],
      step_pixels_attributes: [:id, :conversion_step_id, :conversion_pixel_html, :conversion_pixel_s2s],
      step_prices_attributes: step_price_attributes
    )
  end

  def step_price_attributes
    [
      :id, :conversion_step_id, :custom_share, :payout_share, :custom_amount, :payout_amount,
      pay_schedules_attributes: pay_schedules_attributes
    ]
  end

  def pay_schedules_attributes
    [
      :id, :true_share, :affiliate_share, :true_pay, :affiliate_pay,
      starts_at_local: [], ends_at_local: []
    ]
  end

  def tracking_params
    params
      .require(:tracking)
      .permit(
        :subid_1, :subid_2, :subid_3, :subid_4, :subid_5, :aff_uniq_id, :deeplink, deeplink_urls: []
      )
      .merge(affiliate_offer: @affiliate_offer)
  end
end
