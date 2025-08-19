class Api::Client::Affiliates::EventAffiliateOffersController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource class: 'AffiliateOffer'

  before_action :destroy_cancelled, only: :create
  before_action :set_attributes, only: :update

  def create
    @event_affiliate_offer.is_subject_to_site_info_check = true

    if @event_affiliate_offer.save
      respond_with @event_affiliate_offer, serializer: Affiliates::EventAffiliateOfferSerializer
    else
      respond_with @event_affiliate_offer, status: :unprocessable_entity
    end
  end

  def get
    @event_affiliate_offer = @event_affiliate_offers.find_by(offer_id: params[:offer_id])
    respond_with @event_affiliate_offer || {}, serializer: Affiliates::EventAffiliateOfferSerializer
  end

  def update
    if @event_affiliate_offer.update(event_affiliate_offer_params)
      if truthy?(event_affiliate_offer_params[:event_contract_signed])
        @event_affiliate_offer.approve_related_affiliate_offer
      end

      respond_with @event_affiliate_offer, serializer: Affiliates::EventAffiliateOfferSerializer
    else
      respond_with @event_affiliate_offer, status: :unprocessable_entity
    end
  end

  private

  def destroy_cancelled
    @event_affiliate_offer.destroy_cancelled
  end

  def set_attributes
    if truthy?(event_affiliate_offer_params[:event_contract_signed])
      @event_affiliate_offer.event_contract_signed_at ||= DateTime.now
      @event_affiliate_offer.event_contract_signed_ip_address ||= request.remote_ip
    elsif @event_affiliate_offer.considered_selected?
      @event_affiliate_offer.approval_status = AffiliateOffer.approval_status_under_evaluation
    end
  end

  def require_params
    params.require(:offer_id) if action_name.to_sym == :get
  end

  def event_affiliate_offer_params
    assign_forex_value_params(event_affiliate_offer: [:requested_affiliate_pay])

    if params[:event_affiliate_offer][:shipping_address_attributes]
      params[:event_affiliate_offer][:shipping_address] =
        params[:event_affiliate_offer].delete(:shipping_address_attributes)
    end

    params.require(:event_affiliate_offer).permit(
      :offer_id, :site_info_id, :event_supplement_notes, :event_shipment_notes, :event_promotion_notes, :phone_number,
      :event_contract_signed, :event_contract_signature, :event_draft_url, :event_draft_notes,
      forex_requested_affiliate_pay: [],
      shipping_address: shipping_address_attributes
    )
  end

  def shipping_address_attributes
    [:address_1, :address_2, :city, :state, :zip_code, :country_id]
  end
end
