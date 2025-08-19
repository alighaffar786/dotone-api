class AffiliateProspectCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_affiliate_ids if params[:affiliate_ids].present?
    filter_by_country_ids if params[:country_ids].present?
    filter_by_media_category_ids if params[:media_category_ids].present?
    filter_by_category_ids if params[:category_ids].present?
    filter_by_appearances if params[:appearances].present?
    filter_by_recruiters if params[:recruiter_ids].present?
  end

  def filter_by_search
    filter do
      @relation.like(params[:search])
    end
  end

  def filter_by_affiliate_ids
    filter { @relation.with_affiliates(params[:affiliate_ids]) }
  end

  def filter_by_country_ids
    filter { @relation.with_countries(params[:country_ids]) }
  end

  def filter_by_media_category_ids
    filter do
      @relation
        .left_joins(site_info: :media_category)
        .where(affiliate_tags: { id: params[:media_category_ids] })
    end
  end

  def filter_by_category_ids
    filter do
      @relation
        .left_joins(:categories)
        .where(categories: { id: params[:category_ids] })
    end
  end

  def filter_by_appearances
    filter do
      @relation
        .left_joins(:site_info)
        .where(site_infos: SiteInfo.with_appearances(params[:appearances]))
    end
  end

  def filter_by_recruiters
    filter do
      @relation.with_recruiters(params[:recruiter_ids])
    end
  end

  def default_sorted
    sort { @relation.order(created_at: :desc) }
  end

  [:username, :url, :followers_count, :appearances].each do |field|
    define_method("sort_by_site_info_#{field}") do
      sort { @relation.left_joins(:site_info).order("site_infos.#{field}" => sort_order) }
    end
  end

end
