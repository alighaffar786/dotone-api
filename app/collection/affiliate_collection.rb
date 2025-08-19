class AffiliateCollection < BaseCollection
  def ensure_filters
    super
    filter_distinct
    filter_by_active if truthy?(params[:active])
    filter_by_statuses if params[:statuses].present?
    filter_by_labels if params[:labels].present?
    filter_by_media_category_ids if params[:media_category_ids].present?
    filter_by_sources if params[:sources].present?
    filter_by_genders if params[:genders].present?
    filter_by_recruiters if params[:recruiter_ids].present?
    filter_by_affiliate_users if params[:affiliate_user_ids].present?
    filter_by_channels if params[:channel_ids].present?
    filter_by_campaigns if params[:campaign_ids].present?
    filter_by_approved_offers if params[:approved_offer_ids].present?
    filter_by_countries if params[:country_ids].present?
    filter_by_rankings if params[:rankings].present?
    filter_by_traffic_quality_levels if params[:traffic_quality_levels].present?
    filter_by_experience_levels if params[:experience_levels].present?
    filter_by_approval_methods if params[:approval_methods].present?
    filter_by_group_tag_ids if params[:group_tag_ids].present?
    filter_by_created_at if params[:start_date].present? && params[:end_date].present?
    filter_by_business_entities if params[:business_entities].present?
    filter_by_email_verified if params.key?(:email_verified)
    filter_by_no_login if truthy?(params[:no_login])
    filter_by_accept_terms if params.key?(:accept_terms)
    filter_by_approved_offer_with_networks if params[:network_id].present?
    filter_by_with_site_info if params.key?(:with_site_info)
  end

  def filter_by_active
    filter { @relation.active }
  end

  def filter_by_statuses
    filter do
      @relation.where(status: params[:statuses])
    end
  end

  def filter_by_approved_offers
    filter do
      @relation
        .joins(:active_affiliate_offers)
        .where(active_affiliate_offers: { offer_id: params[:approved_offer_ids] })
    end
  end

  def filter_by_approved_offer_with_networks
    filter do
      network = Network.cached_find(params[:network_id])
      @relation
        .joins(:active_affiliate_offers)
        .where(active_affiliate_offers: { offer_id: network.network_offers })
    end
  end

  def filter_by_with_site_info
    filter do
      if truthy?(params[:with_site_info])
        @relation.joins(:site_infos)
      else
        @relation.left_outer_joins(:site_infos).where(site_infos: { id: nil })
      end
    end
  end

  def filter_by_labels
    filter do
      @relation.where(label: params[:labels])
    end
  end

  def filter_by_media_category_ids
    filter do
      @relation
        .joins(site_infos: :media_category)
        .where(affiliate_tags: { id: params[:media_category_ids] })
    end
  end

  def filter_by_sources
    filter do
      @relation.where(source: params[:sources])
    end
  end

  def filter_by_genders
    filter do
      @relation.where(gender: params[:genders])
    end
  end

  def filter_by_recruiters
    filter do
      @relation.with_recruiters(params[:recruiter_ids])
    end
  end

  def filter_by_affiliate_users
    filter do
      @relation.joins(:affiliate_users).where(affiliate_users: { id: params[:affiliate_user_ids] })
    end
  end

  def filter_by_countries
    filter do
      @relation.joins(:affiliate_address).with_countries(params[:country_ids])
    end
  end

  def filter_by_channels
    filter do
      @relation.with_channels(params[:channel_ids])
    end
  end

  def filter_by_campaigns
    filter do
      @relation.with_campaigns(params[:campaign_ids])
    end
  end

  def filter_by_rankings
    filter { @relation.where(ranking: params[:rankings]) }
  end

  def filter_by_traffic_quality_levels
    filter { @relation.where(traffic_quality_level: params[:traffic_quality_levels]) }
  end

  def filter_by_experience_levels
    filter { @relation.where(experience_level: params[:experience_levels]) }
  end

  def filter_by_approval_methods
    filter { @relation.where(approval_method: params[:approval_methods]) }
  end

  def sort_by_company_name
    sort do
      @relation
        .select('affiliates.*, affiliate_applications.company_name')
        .left_joins(:affiliate_application)
        .order('affiliate_applications.company_name' => sort_order)
    end
  end

  def sort_by_country
    sort do
      @relation
        .select('affiliates.*, countries.name')
        .left_joins(:country)
        .order('countries.name' => sort_order)
    end
  end

  def sort_by_campaign
    sort do
      @relation
        .select('affiliates.*, campaigns.name')
        .left_joins(:campaign)
        .order('campaigns.name' => sort_order)
    end
  end

  def sort_by_channel
    sort do
      @relation
        .select('affiliates.*, channels.name')
        .left_joins(:channel)
        .order('channels.name' => sort_order)
    end
  end

  def filter_by_business_entities
    filter { @relation.where(business_entity: params[:business_entities]) }
  end

  def filter_by_email_verified
    filter { @relation.where(email_verified: truthy?(params[:email_verified])) }
  end

  def filter_by_no_login
    filter { @relation.where(login_count: [0, nil]) }
  end

  def filter_by_accept_terms
    filter { @relation.with_accept_terms(params[:accept_terms]) }
  end
end
