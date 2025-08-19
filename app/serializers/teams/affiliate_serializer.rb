class Teams::AffiliateSerializer < Base::AffiliateSerializer
  class PaymentInfoSerializer < Base::AffiliatePaymentInfoSerializer
    attributes :id, :preferred_currency_name, :preferred_currency_id, :preferred_currency, :status
  end

  attributes :id

  conditional_attributes :first_name, :last_name, :name, :status, :email, :username, :email_verified, :experience_level, :birthday, :gender,
    :ssn_ein, :traffic_quality_level, :business_entity, :nickname, :tax_filing_country, :tax_filing_country_id, :ranking,
    :referral_expired_at, :internal_notes, :affiliate_user_ids, :recruiter_id, :recruited_at, :label, :hash_tokens, :s2s_global_pixel,
    :legal_resident_address, :referrer_id, :group_tag_ids, :payment_term, :company?, :referral_count, :tfa_enabled,
    :messenger_service, :messenger_service_2, :messenger_id, :messenger_id_2, :approval_method, :previous_balance, if: :can_read_affiliate?

  has_many :site_infos
  has_many :affiliate_users
  has_many :media_categories, serializer: AffiliateTag::MediaCategorySerializer
  has_many :group_tags
  has_many :admin_logs, key: :affiliate_logs

  has_one :affiliate_application
  has_one :referrer, serializer: Teams::Affiliate::MiniSerializer
  has_one :affiliate_address
  has_one :recruiter
  has_one :payment_info, serializer: PaymentInfoSerializer
end
