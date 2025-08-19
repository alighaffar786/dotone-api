class Api::Client::Affiliates::AffiliateOffersController < Api::Client::Affiliates::BaseController
  include DotOne::Track

  load_and_authorize_resource

  before_action :destroy_cancelled, only: :create
  after_action :record_usage, only: :generate_url

  def create
    @affiliate_offer.is_subject_to_site_info_check = true

    if @affiliate_offer.save
      respond_with @affiliate_offer
    else
      respond_with @affiliate_offer, status: :unprocessable_entity
    end
  end

  def get
    @affiliate_offer = @affiliate_offers.find_by(offer_id: params[:offer_id])
    respond_with @affiliate_offer || {}
  end

  def update
    if @affiliate_offer.update(affiliate_offer_params)
      respond_with @affiliate_offer
    else
      respond_with @affiliate_offer, status: :unprocessable_entity
    end
  end

  def generate_url
    authorize! :generate_url, @affiliate_offer
    @collection = ClickUrlSet.new(tracking_params).generate
    respond_with @collection
  end

  def destroy
    @affiliate_offer.update(approval_status: AffiliateOffer.approval_status_cancelled)
    head :ok
  end

  private

  def require_params
    params.require(:offer_id) if action_name.to_sym == :get
  end

  def record_usage
    return unless (value = @collection&.find { |v| [:tracking_url, :deeplink_url].include?(v[:key]) })
    url = value[:url]

    if url.present?
      AlternativeDomain.queue_record_tracking_usage(value[:url])
    elsif Rails.env.production?
      Sentry.capture_exception(Exception.new("Tracking URL was not generated for #{params}"))
    end
  end

  def destroy_cancelled
    @affiliate_offer.destroy_cancelled
  end

  def tracking_params
    params.require(:tracking).permit(
      :offer_variant_id, :subid_1, :subid_2, :subid_3, :subid_4, :subid_5, :t, :aff_uniq_id, :for_social, :deeplink,
      :include_direct_url, deeplink_urls: []
    ).merge(
      affiliate: current_user,
      affiliate_offer: @affiliate_offer,
    )
  end

  def affiliate_offer_params
    params.require(:affiliate_offer).permit(:offer_id, :claim_message, :backup_redirect, :reapply_note)
  end
end
