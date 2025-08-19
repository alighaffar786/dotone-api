class Api::Client::Affiliates::RegistrationsController < Api::Client::Affiliates::BaseController
  def register
    authorize! :signup, Affiliate
    @affiliate = Affiliate.new(registration_params)

    if captcha_verified? && @affiliate.save
      send_verification
      respond_with @affiliate
    else
      respond_with @affiliate, status: :unprocessable_entity
    end
  end

  def resend_verification
    authorize! :verify, Affiliate
    @affiliate = Affiliate.find_by_email(params[:email])

    if @affiliate
      send_verification
      head :ok
    else
      head :not_found
    end
  end

  def verify
    authorize! :verify, Affiliate
    @affiliate = Affiliate.find_by_unique_token(params[:token])

    if @affiliate
      @affiliate.mark_as_verified!
      @affiliate.refresh_unique_token
      head :ok
    else
      render json: { message: 'Invalid Token' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordInvalid
    respond_with @affiliate, status: :unprocessable_entity
  end

  private

  def send_verification
    AffiliateMailer.verification_instructions(@affiliate).deliver_later
  end

  def registration_params
    params.require(:registration).permit(
      :email, :business_entity, :first_name, :last_name, :password, :locale, :birthday, :gender,
      affiliate_address_attributes: [:country_id], affiliate_application_attributes: [:company_name]
    )
  end

  def captcha_verified?
    verify_recaptcha(
      model: @affiliate,
      action: 'affiliate/register',
      minimum_score: ENV.fetch('RECAPTCHA_MINIMUM_SCORE', 0.5).to_f,
      response: params[:g_recaptcha_response],
    )
  end
end
