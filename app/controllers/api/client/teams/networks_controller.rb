class Api::Client::Teams::NetworksController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: [:create, :search, :overview, :generate_auto_auth_token]
  load_and_authorize_resource through: :current_user, only: :create
  load_resource only: :generate_auto_auth_token

  before_action :validate_origin_presence, only: :generate_auto_auth_token

  def index
    @networks = paginate(query_index)
    respond_with_pagination @networks, each_serializer: Teams::Network::IndexSerializer
  end

  def create
    @network.sales_pipeline = Network.sales_pipeline_qualified_lead if @network.new?

    if can?(:recruit, @network)
      @network.recruiter = current_user
      @network.recruited_at = Time.now
    end

    if @network.save
      respond_with @network
    else
      respond_with @network, status: :unprocessable_entity
    end
  end

  def show
    respond_with @network
  end

  def update
    if @network.update(network_params)
      respond_with @network
    else
      respond_with @network, status: :unprocessable_entity
    end
  end

  def search
    authorize! :read, Network
    @networks = query_search
    respond_with @networks, each_serializer: Teams::Network::SearchSerializer, full_scope: full_scope?
  end

  def current_balance
    respond_with({ id: @network.id, value: @network.forex_current_balance(current_currency_code) })
  end

  def bulk_update
    authorize! :update, Network
    start_bulk_update_job(
      Networks::BulkUpdateJob,
      network_bulk_update_params,
    )
    head :ok
  end

  def download
    @download = build_download(query_index, current_columns)
    authorize! :create, @download
    authorize! :download, Network

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def generate_auto_auth_token
    authorize! :login_as, @network

    @network.refresh_unique_token if @network.unique_token.blank?
    token = DotOne::Utils::JsonWebToken.encode(
      unique_token: @network.unique_token,
      request_host: URI(request.origin).host,
    )
    render json: { token: token }
  end

  def overview
    authorize! :read, Network
    respond_with query_overview
  end

  def deliver_stat_summary
    if @network.stat_summary_notification_on?
      AdvertiserMailer.stat_summary(@network).deliver_later
    end

    head :ok
  end

  private

  def query_search
    collection = NetworkCollection.new(current_ability, params, **current_options).collect
    collection = collection.preload(:country, :category_groups, :contact_lists) if full_scope?
    collection
  end

  def query_index
    NetworkCollection.new(current_ability, params, **current_options.merge(authorize: :update))
      .collect
      .preload(
        :affiliate_users, :category_groups, :recruiter, :country, :billing_currency, :channel, :campaign, :contact_lists,
        admin_logs: [:agent, :crm_infos, crm_info: :crm_target],
      )
  end

  def query_overview
    networks = Network.accessible_by(current_ability)
    result = networks.group(:status).count.transform_keys { |key| key.downcase }
    email_unverified = networks.where(email_verified: false).considered_valid.count

    result.merge(email_unverified: email_unverified)
  end

  def network_params
    if current_user.manager? && @network.present? && @network.affiliate_user_ids.exclude?(current_user.id) && @network.recruiter_id != current_user.id
      params[:network].delete(:status)
      params[:network].delete(:sales_pipeline)
    end

    params[:network].delete(:password) if params[:network][:password].blank?

    assign_local_time_params(network: [:recruited_at, :published_date])

    params.require(:network).permit(
      :contact_email, :password, :status, :name, :contact_name, :contact_phone, :contact_title, :company_url,
      :address_1, :address_2, :city, :state, :zip_code, :country_id, :billing_name, :billing_email, :billing_phone_number,
      :payment_term, :payment_term_days, :billing_currency_id, :billing_region, :sales_tax, :universal_number, :redirect_url,
      :client_notes, :private_notes, :recruiter_id, :ip_address_white_listed, :dns_white_listed, :skip_validation, :tfa_enabled,
      :blacklisted_referer_domain, :blacklisted_subids, :do_notify_status_change, :grade, :sales_pipeline, :subscription,
      notification: [:stat_summary], category_group_ids: [], recruited_at_local: [], published_date_local: [],
      affiliate_user_ids: [], brands: [],
      s2s_params: [:server_subid, :order, :order_total, :revenue],
    )
  end

  def network_bulk_update_params
    params.require(:network).permit(:recruiter_id, add_affiliate_user_ids: [], remove_affiliate_user_ids: []).tap do |param|
      param[:recruited_at] = Time.now if param[:recruiter_id].present?
    end
  end
end
