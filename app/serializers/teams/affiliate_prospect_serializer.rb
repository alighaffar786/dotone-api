class Teams::AffiliateProspectSerializer < ApplicationSerializer
  class AffiliateSerializer < Base::AffiliateSerializer
    attributes :id
    attribute :name, if: :can_read_affiliate?
  end

  class SiteInfoSerializer < Teams::SiteInfo::MiniSerializer
    attributes :username, :followers_count, :appearances, :media_category_id, :affiliate_id

    has_one :media_category
  end

  attributes :id, :email, :category_ids, :affiliate_id, :country_id

  has_many :categories
  has_many :affiliate_logs

  has_one :country
  has_one :site_info, serializer: SiteInfoSerializer
  has_one :affiliate, serializer: AffiliateSerializer
  has_one :recruiter, serializer: Teams::AffiliateUser::MiniSerializer
end
