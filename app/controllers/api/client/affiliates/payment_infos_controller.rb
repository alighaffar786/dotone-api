class Api::Client::Affiliates::PaymentInfosController < Api::Client::Affiliates::BaseController

  def show
    authorize! :read, payment_info
    respond_with payment_info
  end

  def update
    authorize! :update, payment_info

    if payment_info.update(payment_info_params)
      respond_with payment_info
    else
      respond_with payment_info, status: :unprocessable_entity
    end
  end

  def verify
    authorize! :update, payment_info
    payment_info.status = AffiliatePaymentInfo.status_waiting_for_verification

    if payment_info.save
      respond_with payment_info
    else
      respond_with payment_info, status: :unprocessable_entity
    end
  end

  private

  def payment_info
    @payment_info ||= current_user.payment_info || current_user.create_payment_info
  end

  def payment_info_params
    params.require(:payment_info).permit(
      :preferred_currency_id, :payment_type, :payee_name, :bank_name, :bank_identification, :branch_key,
      :bank_address, :routing_number, :account_number, :paypal_email_address, :iban, affiliate_attributes: affiliate_attributes
    )
  end

  def affiliate_attributes
    [
      :id, :tax_filing_country_id, :business_entity, :ssn_ein, :legal_resident_address,
      :front_of_id_link, :back_of_id_link, :valid_id_link, :bank_booklet_link, :tax_form_link, affiliate_application_attributes: [:id, :company_name]
    ]
  end
end
