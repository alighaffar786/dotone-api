class Api::Client::Teams::AdvertiserBalancesController < Api::Client::Teams::BaseController

  load_and_authorize_resource
  load_and_authorize_resource :upload, only: :import, id_param: :upload_id
  before_action :ignore_balance_type, only: :download_remaining

  def index
    @advertiser_balances = paginate(query_index)
    respond_with_pagination @advertiser_balances
  end

  def remaining
    collection = query_remaining
    @advertiser_balances = collection.is_a?(Array) ? array_paginate(collection) : paginate(collection)

    respond_with_pagination @advertiser_balances,
      each_serializer: Teams::AdvertiserBalance::RemainingSerializer,
      pending_payouts: pending_payouts,
      published_payouts: published_payouts,
      meta: { total: query_total(collection) }
  end

  def create
    if @advertiser_balance.save
      respond_with @advertiser_balance
    else
      respond_with @advertiser_balance, status: :unprocessable_entity
    end
  end

  def update
    if @advertiser_balance.update(advertiser_balance_params)
      respond_with @advertiser_balance
    else
      respond_with @advertiser_balance, status: :unprocessable_entity
    end
  end

  def download
    @download = build_download(query_index, current_columns)
    authorize! :create, @download
    authorize! :download, AdvertiserBalance

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def download_remaining
    @download = build_download(query_remaining)
    @download.name = 'Advertiser Remaining Balance'
    @download.headers = AdvertiserBalance.generate_remaining_download_headers

    authorize! :create, @download
    authorize! :download, AdvertiserBalance

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def import
    authorize! :create, AdvertiserBalance
    AdvertiserBalances::ImportJob.perform_later(@upload.id)
    head :ok
  end

  private

  def query_index
    AdvertiserBalanceCollection.new(@advertiser_balances, params)
      .collect
      .preload(network: :billing_currency)
  end

  def query_remaining
    collection = AdvertiserBalanceCollection.new(current_ability, params)
      .collect
      .agg_final_balance
      .preload(network: :billing_currency)

    if params[:balance_type].present?
      collection.each do |balance|
        network = balance.network
        network.current_balance = balance.forex_final_balance
        network.pending_payout = pending_payouts[balance.network_id]&.pending_true_pay.to_f
        network.published_payout = published_payouts[balance.network_id]&.published_true_pay.to_f
      end

      case params[:balance_type].to_sym
      when :positive
        return collection.select { |balance| balance.network.remaining_balance >= 0 }
      when :negative
        return collection.select { |balance| balance.network.remaining_balance < 0 }
      end
    end

    collection
  end

  def query_total(collection)
    network_ids = collection.map(&:network_id)

    final_balance = collection.sum(&:forex_final_balance)
    pending_payout = pending_payouts.slice(*network_ids).values.map { |stat| stat.pending_true_pay.round(2) }.sum
    published_payout = published_payouts.slice(*network_ids).values.map { |stat| stat.published_true_pay.round(2) }.sum
    remaining_balance = final_balance - pending_payout - published_payout

    {
      final_balance: final_balance,
      pending_payout: pending_payout,
      published_payout: published_payout,
      remaining_balance: remaining_balance
    }
  end

  def pending_payouts
    @pending_payouts ||= fetch_cached([], self.class.name, :query_pending_payouts, expires_in: 30.minutes) do
      Stat.network_pending_payouts
    end
  end

  def published_payouts
    @published_payouts ||= fetch_cached([], self.class.name, :query_published_payouts, expires_in: 30.minutes) do
      Stat.network_published_payouts
    end
  end

  def ignore_balance_type
    params.delete(:balance_type)
  end

  def advertiser_balance_params
    assign_local_time_params(advertiser_balance: [:recorded_at, :invoice_date])

    params.require(:advertiser_balance).permit(
      :network_id, :invoice_number, :record_type, :notes, :credit, :debit, :sales_tax, :invoice_amount,
      invoice_date_local: [], recorded_at_local: []
    )
  end
end
