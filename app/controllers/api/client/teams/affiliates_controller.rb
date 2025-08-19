class Api::Client::Teams::AffiliatesController < Api::Client::Teams::BaseController
  load_and_authorize_resource except: [:search, :overview]

  before_action :validate_origin_presence, only: :generate_auto_auth_token

  def index
    @affiliates = paginate(query_index)
    respond_with_pagination @affiliates, each_serializer: Teams::Affiliate::IndexSerializer,
      impressions: query_impressions, top_offers: query_top_offers
  end

  def create
    if can?(:recruit, @affiliate)
      @affiliate.recruiter = current_user
      @affiliate.recruited_at = Time.now
    end

    if @affiliate.save
      respond_with @affiliate
    else
      respond_with @affiliate, status: :unprocessable_entity
    end
  end

  def show
    respond_with @affiliate
  end

  def update
    if @affiliate.update(affiliate_params)
      respond_with @affiliate
    else
      respond_with @affiliate, status: :unprocessable_entity
    end
  end

  def search
    authorize! :read, Affiliate
    respond_with query_search, each_serializer: Teams::Affiliate::SearchSerializer, full_scope: full_scope?
  end

  def generate_auto_auth_token
    authorize! :login_as, @affiliate

    @affiliate.refresh_unique_token if @affiliate.unique_token.blank?
    token = DotOne::Utils::JsonWebToken.encode(
      unique_token: @affiliate.unique_token,
      request_host: URI(request.origin).host,
    )
    render json: { token: token }
  end

  def bulk_update
    authorize! :update, Affiliate
    start_bulk_update_job(
      Affiliates::BulkUpdateJob,
      affiliate_bulk_update_params,
    )
    head :ok
  end

  def download
    @download = build_download(query_index, current_columns)
    authorize! :create, @download
    authorize! :download, Affiliate

    if @download.save
      start_download_job(@download)
      respond_with @download
    else
      respond_with @download, status: :unprocessable_entity
    end
  end

  def overview
    authorize! :read, Affiliate
    respond_with query_overview
  end

  private

  def query_index
    collection = AffiliateCollection.new(current_ability, params, **current_options.merge(authorize: :update)).collect
    collection.preload(
      :country, :referrer, :recruiter, :affiliate_users, :contact_lists,
      :channel, :campaign, :avatar, :affiliate_application, :aff_hash, :group_tags,
      media_categories: :parent_category,
      site_infos: [:categories, :site_info_categories, :site_info_tag, media_category: :parent_category],
      admin_logs: [:agent, :crm_infos, crm_info: :crm_target]
    )
  end

  def query_search
    collection = AffiliateCollection.new(current_ability, params).collect
    collection = collection.preload(:affiliate_address, :country, :aff_hash, :affiliate_application) if full_scope?
    collection
  end

  def query_impressions
    UniqueViewStat.select('SUM(count) AS count', :affiliate_id, :date)
      .where(affiliate_id: @affiliates.map(&:id))
      .last_30_days
      .group(:date, :affiliate_id)
      .group_by(&:affiliate_id)
      .transform_values { |stats| stats.index_by(&:date) }
  end

  def query_top_offers
    top_offer_ids = @affiliates.flat_map(&:top_offer_ids).uniq
    top_offer_ids.present? ? NetworkOffer.accessible_by(current_ability).where(id: top_offer_ids).preload_translations(:name) : []
  end

  def query_overview
    affiliates = Affiliate.accessible_by(current_ability)
    result = affiliates.group(:status).count.transform_keys { |key| key.downcase }
    valid_affiliates = affiliates.considered_valid

    result.merge(
      no_accept_terms: valid_affiliates.with_accept_terms(false).count,
      email_unverified: valid_affiliates.where(email_verified: false).count,
      no_login: valid_affiliates.where(login_count: [0, nil]).count,
    )
  end

  def affiliate_params
    assign_local_time_params({ affiliate_application_attributes: [:accept_terms_at, :age_confirmed_at] }, params[:affiliate])
    assign_local_time_params(affiliate: [:recruited_at])

    params.require(:affiliate)
      .permit(
        :status, :email, :email_verified, :password, :label, :first_name, :last_name, :username, :birthday, :gender, :ranking,
        :traffic_quality_level, :experience_level, :referrer_id, :referral_expired_at, :business_entity,
        :messenger_id, :messenger_id_2, :messenger_service, :messenger_service_2, :tfa_enabled,
        :legal_resident_address, :tax_filing_country_id, :ssn_ein, :internal_notes, :recruiter_id, :s2s_global_pixel, :payment_term, :approval_method,
        affiliate_user_ids: [], recruited_at_local: [], category_group_ids: [], group_tag_ids: [], hash_tokens: [:key, :value],
        affiliate_application_attributes: [
          :id, :accept_terms, :age_confirmed, :phone_number, :time_to_call, :company_name, :company_site,
          :facebook, :twitter, :linkedin, :pinterest, :tumbler, :skype, :line, :qq, :wechat,
          accept_terms_at_local: [], age_confirmed_at_local: []
        ],
        payment_info_attributes: [:id, :preferred_currency_id],
        affiliate_address_attributes: [
          :id, :address_1, :address_2, :city, :state, :zip, :country_id
        ]
      )
      .reject { |key, value| key == :password && value.blank? }
  end

  def affiliate_bulk_update_params
    params.require(:affiliate).permit(:recruiter_id, add_affiliate_user_ids: [], remove_affiliate_user_ids: []).tap do |param|
      param[:recruited_at] = Time.now if param[:recruiter_id].present?
    end
  end
end
