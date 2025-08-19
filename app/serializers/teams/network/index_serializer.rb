class Teams::Network::IndexSerializer < Base::NetworkSerializer
  attributes :id

  conditional_attributes :brands, :contact_email, :company_url, :name, :contact_name, :contact_phone, :contact_title, :pro?, :status,
    :created_at, :published_date, :transaction_affiliate, :transaction_subid_1, :transaction_subid_2, :transaction_subid_3,
    :transaction_subid_4, :transaction_subid_5, :channel_id, :payment_term, :profile_updated_at, :note_updated_at,
    :billing_region, :billing_currency_id, :recruiter_id, :recruited_at, :affiliate_user_ids, :sales_pipeline, :grade,
    :subscription, if: :can_read_network?

  has_many :affiliate_users, serializer: Teams::AffiliateUser::MiniSerializer
  has_many :admin_logs, key: :affiliate_logs
  has_many :contact_lists
  has_many :category_groups

  has_one :recruiter, serializer: Teams::AffiliateUser::MiniSerializer
  has_one :country
  has_one :transaction_affiliate, serializer: Teams::Affiliate::MiniSerializer
  has_one :campaign, serializer: Teams::Campaign::MiniSerializer
  has_one :channel, serializer: Teams::Channel::MiniSerializer
  has_one :billing_currency
end
