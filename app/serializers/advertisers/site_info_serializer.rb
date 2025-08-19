class Advertisers::SiteInfoSerializer < Base::SiteInfoSerializer
  attributes :id, :account_id, :account_type, :verified?, :integrated?, :ad_link_applicable?, :integration_applicable?,
    :verifiable?

  conditional_attributes :url, :unique_visit_per_day, :unique_visit_per_month, :comments, :description,
    :followers_count, :impression_available?, if: :include_details?

  has_many :categories, if: :include_details?

  has_one :media_category, serializer: AffiliateTag::MediaCategorySerializer

  def include_details?
    partial_pro_network? || pro_network? || object.affiliate.direct?
  end
end
