class Api::Client::Advertisers::AffiliateOffersController < Api::Client::Advertisers::BaseController
  load_and_authorize_resource

  def index
    @affiliate_offers = paginate(query_index)
    respond_with_pagination @affiliate_offers
  end

  def update
    if @affiliate_offer.update(affiliate_offer_params)
      respond_with @affiliate_offer
    else
      respond_with @affiliate_offer, status: :unprocessable_entity
    end
  end

  private

  def query_index
    AffiliateOfferCollection.new(current_ability, params)
      .collect
      .preload(
        network_logs: :agent,
        step_prices: [:true_currency, :active_pay_schedule],
        default_conversion_step: [:true_currency, :label_translations, :active_pay_schedule],
        offer: [:name_translations],
        affiliate: [:avatar, :aff_hash, :affiliate_application],
      )
  end

  def affiliate_offer_params
    params
      .require(:affiliate_offer)
      .permit(:approval_status)
      .tap do |param|
        param.delete(:approval_status) if accepted_statuses.exclude?(param[:approval_status])
      end
  end

  def accepted_statuses
    [
      AffiliateOffer.approval_status_pending,
      AffiliateOffer.approval_status_active,
      AffiliateOffer.approval_status_paused,
      AffiliateOffer.approval_status_suspended,
    ]
  end
end
