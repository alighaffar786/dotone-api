class Api::Client::Affiliates::PhoneVerificationsController < Api::Client::Affiliates::BaseController
  load_and_authorize_resource except: :create

  def create
    @phone_verification = PhoneVerification
      .accessible_by(current_ability, :create)
      .where(phone_number: PhoneVerification.sanitize_phone_number(params[:phone_number]))
      .first_or_initialize

    authorize! :create, @phone_verification

    if @phone_verification.create_or_resend
      respond_with @phone_verification
    else
      respond_with @phone_verification, status: :unprocessable_entity
    end
  end

  def verify
    if @phone_verification.verify(params[:otp])
      respond_with @phone_verification
    else
      respond_with @phone_verification, status: :unprocessable_entity
    end
  end
end
