class Api::V2::Affiliates::DeepLinksController < Api::V2::Affiliates::BaseController
  before_action :set
  before_action :validate

  def generate
    authorize! :read, @offer
    respond_with({ data: tracking_urls })
  end

  private

  def require_params
    params.require([:offer_id, :data])
  end

  def data_params
    params.permit(data: [:target_url, :aff_uniq_id, :subid_1, :subid_2, :subid_3, :subid_4, :subid_5])
  end

  def set
    @offer = NetworkOfferCollection.new(current_ability, can_config_url: true).collect.find(params[:offer_id])
    @campaign = AffiliateOffer.active_best_match(current_user, @offer)
  end

  def validate
    raise DotOne::Errors::ApiRequestError.new(nil, 'api_request.missing_campaign') if @campaign.blank?
  end

  def tracking_urls
    data = []

    data_params[:data].each_with_index do |item, index|
      resp = { index: index }
      target_url = item.delete(:target_url)

      unless DotOne::Utils::Url.is_valid_url?(target_url)
        raise DotOne::Errors::InvalidDataError.new(target_url, 'data.invalid_url', 'target_url')
      end

      unless @offer.destination_match?(target_url)
        raise DotOne::Errors::InvalidDataError.new(target_url, 'data.mismatch_with_merchant_url', 'target_url')
      end

      resp[:deeplink_url] = @campaign.to_tracking_url(item.merge(t: target_url).to_h)

      data << resp
    end

    data
  end
end
