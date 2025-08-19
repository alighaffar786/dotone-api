class Teams::SiteInfoSerializer < Base::SiteInfoSerializer
  attributes :id, :affiliate_id, :url, :description, :comments, :unique_visit_per_day, :unique_visit_per_month, :auto_added?,
    :verified?, :brand_domain_opt_outs, :page_url_opt_outs, :account_id, :account_type, :category_ids, :media_count,
    :followers_count, :media_category_id, :ad_link_enabled, :parent_category_id, :ad_link_applicable?, :integration_applicable?,
    :integrated?, :verifiable?, :created_at

  conditional_attributes :impressions, if: :impressions?

  has_many :categories

  has_one :media_category, serializer: AffiliateTag::MediaCategorySerializer

  def impressions?
    object.impression_available? && instance_options[:impressions].present?
  end

  def impressions
    (30.days.ago.to_date..Date.today).to_h do |date|
      impression = instance_options.dig(:impressions, object.affiliate_id, date)

      [date.to_s, impression&.count || 0]
    end
  end
end
