class Api::Client::Teams::AffiliatePaymentsController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: :create_proposal
  load_and_authorize_resource :upload, only: :import, id_param: :upload_id

  def index
    @affiliate_payments = paginate(query_index)
    respond_with_pagination @affiliate_payments, total_fees: query_total_fees
  end

  def bulk_edit
    authorize! :update, AffiliatePayment
    @affiliate_payments = query_bulk(:update)
    start_bulk_update_job
    head :ok
  end

  def bulk_delete
    authorize! :destroy, AffiliatePayment
    # prevent to delete all records
    if params[:ids].present?
      @affiliate_payments = query_bulk(:destroy)
      @affiliate_payments.destroy_all
      head :ok
    else
      head :bad_request
    end
  end

  def download
    @download = build_download(query_index)
    authorize! :create, @download
    authorize! :download, AffiliatePayment

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def create
    if @affiliate_payment.save
      respond_with @affiliate_payment
    else
      respond_with @affiliate_payment, status: :unprocessable_entity
    end
  end

  def update
    if @affiliate_payment.update(affiliate_payment_params)
      respond_with @affiliate_payment
    else
      respond_with @affiliate_payment, status: :unprocessable_entity
    end
  end

  def import
    authorize! :create, AffiliatePayment
    AffiliatePayments::ImportJob.perform_later(@upload.id)
    head :ok
  end

  def create_proposal
    @download = Download.new(
      name: 'Affiliate Payment Proposal',
      notes: proposal_notes,
      owner: current_user,
      downloaded_by: current_user&.name_with_role,
    )
    authorize! :create, @download
    authorize! :create, AffiliatePayment

    if @download.save
      start_proposal_job
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  private

  def query_index
    collection = AffiliatePaymentCollection.new(@affiliate_payments, params, **current_options).collect
    collection.preload(:affiliate_users, :wire_fee, :tax_fee, affiliate: :affiliate_application)
  end

  def query_total_fees
    PaymentFee
      .where(affiliate_payment_id: @affiliate_payments.map(&:id))
      .group(:affiliate_payment_id)
      .sum(:amount)
  end

  def query_bulk(rule)
    AffiliatePaymentCollection.new(current_ability, params, **current_options.merge(authorize: rule))
      .collect
  end

  def start_bulk_update_job
    AffiliatePayments::BulkUpdateJob.perform_later(
      @affiliate_payments.pluck(:id),
      params.require(:affiliate_payment).permit(:status),
    )
  end

  def affiliate_payment_params
    params
      .require(:affiliate_payment)
      .permit(
        :affiliate_id, :start_date, :end_date, :paid_date, :notes, :billing_region,
        :previous_amount, :affiliate_amount, :referral_amount, :redeemed_amount, :has_invoice, :amount, :balance, :status,
        :wire_fee_amount, :tax_fee_amount,
      )
  end

  def start_proposal_job
    AffiliatePayments::CreateProposalJob.perform_later(
      proposal_params.merge(download_id: @download.id).to_h.symbolize_keys
    )
  end

  def proposal_params
    params.require(:affiliate_payment).permit(:start_date, :end_date, :paid_date)
  end

  def proposal_notes
    notes = []
    proposal_params.each do |key, value|
      notes << "#{DotOne::I18n.download_t("affiliate_payment.#{key}")}: #{value}"
    end
    notes.join('<br>')
  end
end
