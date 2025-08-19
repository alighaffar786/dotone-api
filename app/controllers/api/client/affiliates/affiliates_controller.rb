class Api::Client::Affiliates::AffiliatesController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource except: :current

  def current
    authorize! :read, current_user
    respond_with current_user, serializer: Affiliates::Affiliate::MiniSerializer
  end

  def show
    respond_with @affiliate
  end

  def update
    if @affiliate.update(affiliate_params)
      respond_with @affiliate
    else
      Sentry.capture_message("Affiliate#update id: #{@affiliate.id}", extra: @affiliate.errors.messages)
      respond_with @affiliate, status: :unprocessable_entity
    end
  end

  def generate_ad_link
    authorize! :generate_ad_link, @affiliate
    @affiliate.generate_ad_link_file!
    respond_with @affiliate
  end

  private

  def affiliate_params
    params
      .require(:affiliate)
      .permit(
        :nickname, :locale, :currency_id, :time_zone_id, :messenger_service, :messenger_service_2, :tfa_enabled, :optout_from_offer_newsletter,
        :messenger_id, :messenger_id_2, :ad_link_terms_accepted, :account_setup_finished, :birthday, :gender, :avatar_cdn_url,
        affiliate_address_attributes: affiliate_address_attributes,
        affiliate_application_attributes: affiliate_application_attributes,
      )
      .tap do |param|
        param[:affiliate_address_attributes][:id] = @affiliate.affiliate_address.id if @affiliate.affiliate_address.present? && param.key?(:affiliate_address_attributes)
        param[:affiliate_application_attributes][:id] = @affiliate.affiliate_application.id if @affiliate.affiliate_application.present? && param.key?(:affiliate_application_attributes)
      end
  end

  def affiliate_address_attributes
    [:address_1, :address_2, :city, :state, :country_id, :zip_code]
  end

  def affiliate_application_attributes
    [:company_site, :age_confirmed, :accept_terms, :phone_number]
  end
end
