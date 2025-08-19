class Affiliates::SiteInfoSerializer < Base::SiteInfoSerializer
  attributes :id, :url, :description, :comments, :unique_visit_per_day, :unique_visit_per_month, :auto_added?, :verified?,
    :brand_domain_opt_outs, :page_url_opt_outs, :account_id, :account_type, :category_ids, :media_count, :followers_count, :error_details,
    :media_category_id, :parent_category_id, :ad_link_enabled, :impressions, :integrated?, :ad_link_applicable?, :integration_applicable?, :verifiable?,
    :connected?

  has_many :categories

  has_one :media_category, serializer: AffiliateTag::MediaCategorySerializer
end
