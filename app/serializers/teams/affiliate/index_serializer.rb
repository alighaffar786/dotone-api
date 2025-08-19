class Teams::Affiliate::IndexSerializer < Base::AffiliateSerializer
  attributes :id

  conditional_attributes :avatar_cdn_url, :source, :label, :direct?, :nickname, :email, :status, :name,
    :company?, :messenger_service,:business_entity, :messenger_service_2, :messenger_id, :messenger_id_2, :transaction_subid_1, :transaction_subid_2,
    :transaction_subid_3, :transaction_subid_4, :transaction_subid_5, :login_count, :ranking, :traffic_quality_level,
    :experience_level, :last_request_at, :conversion_count, :email_verified, :created_at, :gender, :birthday,
    :affiliate_user_ids, :recruiter_id, :recruited_at, if: :can_read_affiliate?

  has_many :admin_logs, key: :affiliate_logs
  has_many :media_categories, serializer: AffiliateTag::MediaCategorySerializer
  has_many :affiliate_users, serializer: Teams::AffiliateUser::MiniSerializer
  has_many :group_tags
  has_many :site_infos
  has_many :contact_lists
  has_many :top_offers, serializer: Teams::NetworkOffer::MiniSerializer

  has_one :country
  has_one :referrer, serializer: Teams::Affiliate::MiniSerializer
  has_one :recruiter, serializer: Teams::AffiliateUser::MiniSerializer
  has_one :affiliate_application
  has_one :transaction_affiliate, serializer: Teams::Affiliate::MiniSerializer
  has_one :channel, serializer: Teams::Channel::MiniSerializer
  has_one :campaign, serializer: Teams::Campaign::MiniSerializer

  def top_offers
    return [] if instance_options[:top_offers].blank?

    object
      .top_offer_ids
      .map do |offer_id|
        instance_options[:top_offers].find { |offer| offer.id == offer_id }
      end
      .compact
  end
end
