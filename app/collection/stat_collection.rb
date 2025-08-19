class StatCollection < BaseCollection
  def ensure_filters
    super

    filter_by_date
    filter_by_billing_region if params[:billing_region].present?
    filter_by_dimension if params[:dimension].present? && Stat.column_names.include?(params[:dimension])
    filter_by_country_ids if params[:country_ids].present?
    filter_by_affiliate_user_ids if params[:affiliate_user_ids].present?
    filter_by_recruiter_ids if params[:recruiter_ids].present?
    filter_by_excluded_affiliate_ids if params[:excluded_affiliate_ids].present?
    filter_by_excluded_network_ids if params[:excluded_network_ids].present?
    filter_by_excluded_offer_ids if params[:excluded_offer_ids].present?
  end

  protected

  def filter_by_date
    filter do
      @relation.between(params[:start_date], params[:end_date], params[:date_type], time_zone)
    end
  end

  def filter_by_billing_region
    filter do
      @relation.with_billing_regions(params[:billing_region])
    end
  end

  def filter_by_dimension
    filter do
      @relation.where("#{params[:dimension]} IS NOT NULL")
    end
  end

  def filter_by_country_ids
    filter do
      @relation.with_countries(params[:country_ids])
    end
  end

  def filter_by_affiliate_user_ids
    filter do
      @relation.with_affiliate_users(params[:affiliate_user_ids])
    end
  end

  def filter_by_recruiter_ids
    filter do
      @relation.with_recruiters(params[:recruiter_ids])
    end
  end

  def filter_by_excluded_affiliate_ids
    filter do
      @relation.where.not(affiliate_id: params[:excluded_affiliate_ids])
    end
  end

  def filter_by_excluded_network_ids
    filter do
      @relation.where.not(network_id: params[:excluded_network_ids])
    end
  end

  def filter_by_excluded_offer_ids
    filter do
      @relation.where.not(offer_id: params[:excluded_offer_ids])
    end
  end
end
