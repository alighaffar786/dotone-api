class NetworkCollection < BaseCollection
  def ensure_filters
    super
    filter_distinct
    filter_by_active if truthy?(params[:active])
    filter_by_statuses if params[:statuses].present?
    filter_by_subscriptions if params[:subscriptions].present?
    filter_by_recruiters if params[:recruiter_ids].present?
    filter_by_affiliate_users if params[:affiliate_user_ids].present?
    filter_by_billing_regions if params[:billing_regions].present?
    filter_by_payment_terms if params[:payment_terms].present?
    filter_by_category_groups if params[:category_group_ids].present?
    filter_by_grades if params[:grades].present?
    filter_by_sales_pipelines if params[:sales_pipelines].present?
    filter_by_channels if params[:channel_ids].present?
    filter_by_campaigns if params[:campaign_ids].present?
    filter_by_profile_updated_at if params[:profile_updated_start_at].present? && params[:profile_updated_end_at].present?
    filter_by_note_updated_at if params[:note_updated_start_at].present? && params[:note_updated_end_at].present?
    filter_by_countries if params[:country_ids].present?
    filter_by_created_at if params[:start_date].present? && params[:end_date].present?
    filter_by_email_verified if params.key?(:email_verified)
  end

  def filter_by_active
    filter { @relation.active }
  end

  def filter_by_statuses
    filter do
      @relation.with_statuses(params[:statuses])
    end
  end

  def filter_by_subscriptions
    filter { @relation.with_subscriptions(params[:subscriptions]) }
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

  def filter_by_billing_regions
    filter do
      @relation.with_billing_regions(params[:billing_regions])
    end
  end

  def filter_by_payment_terms
    filter do
      @relation.with_payment_terms(params[:payment_terms])
    end
  end

  def filter_by_countries
    filter do
      @relation.with_countries(params[:country_ids])
    end
  end

  def filter_by_category_groups
    filter do
      @relation.with_category_groups(params[:category_group_ids])
    end
  end

  def filter_by_sales_pipelines
    filter do
      @relation.with_sales_pipelines(params[:sales_pipelines])
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

  def filter_by_profile_updated_at
    filter do
      @relation.between(params[:profile_updated_start_at], params[:profile_updated_end_at], :profile_updated_at, any: true)
    end
  end

  def filter_by_note_updated_at
    filter do
      @relation.between(params[:note_updated_start_at], params[:note_updated_end_at], :note_updated_at, any: true)
    end
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end

  def sort_by_date
    sort { @relation.order(created_at: sort_order) }
  end

  def filter_by_grades
    filter do
      @relation.where(grade: params[:grades])
    end
  end

  def filter_by_email_verified
    filter { @relation.where(email_verified: truthy?(params[:email_verified])) }
  end
end
