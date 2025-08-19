class Api::Client::Teams::AffiliatePaymentInfosController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :show
  load_and_authorize_resource :affiliate, only: :show

  def index
    @affiliate_payment_infos = paginate(query_index)
    respond_with_pagination @affiliate_payment_infos
  end

  def show
    @affiliate_payment_info = @affiliate.payment_info || @affiliate.create_payment_info
    authorize! :read, @affiliate_payment_info
    respond_with @affiliate_payment_info
  end

  def update
    @affiliate_payment_info.skip_validate_status = true

    if @affiliate_payment_info.update(affiliate_payment_info_params)
      respond_with @affiliate_payment_info
    else
      respond_with @affiliate_payment_info, status: :unprocessable_entity
    end
  end

  def download
    @download = build_download(query_index, current_columns)
    authorize! :create, @download
    authorize! :download, AffiliatePaymentInfo

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = AffiliatePaymentInfoCollection.new(@affiliate_payment_infos, params, **current_options).collect
    collection.preload(
      :currency, :affiliate_address,
      affiliate: [
        :aff_hash, :affiliate_application, :affiliate_assignments, :affiliate_users,
        :front_of_id, :back_of_id, :bank_booklet, :tax_form, :valid_id
      ]
    )
  end

  def affiliate_payment_info_params
    params
      .require(:affiliate_payment_info)
      .permit(
        :status, :preferred_currency_id, :payee_name, :bank_identification, :bank_name, :branch_key,
        :bank_address, :iban, :routing_number, :account_number, :paypal_email_address, :payment_type, :affiliate_id,
        affiliate_attributes: [
          :id, :business_entity, :ssn_ein, :tax_filing_country_id, :legal_resident_address,
          affiliate_application_attributes: [:id, :company_name]
        ]
      )
  end
end
