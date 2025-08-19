class Teams::NetworkSerializer < Base::NetworkSerializer
  attributes :id

  conditional_attributes :country_id, :brands, :billing_currency_id, :contact_email, :name, :contact_name, :contact_phone, :contact_title,
    :pro?, :status, :transaction_affiliate, :transaction_subid_1, :transaction_subid_2, :transaction_subid_3,
    :transaction_subid_4, :transaction_subid_5, :channel_id, :profile_updated_at, :note_updated_at,
    :recruiter_id, :recruited_at, :affiliate_user_ids, :company_url, :address_1, :address_2, :city, :state, :zip_code,
    :billing_name, :billing_email, :billing_phone_number, :billing_region, :payment_term, :payment_term_days, :sales_tax,
    :universal_number, :redirect_url, :client_notes, :private_notes, :category_group_ids,
    :ip_address_white_listed, :dns_white_listed, :blacklisted_referer_domain, :blacklisted_subids, :sales_pipeline, :grade,
    :subscription, :published_date, :created_at, :notification, :s2s_params, :tfa_enabled, if: :can_read_network?

  has_many :affiliate_users
  has_many :admin_logs, key: :affiliate_logs
  has_many :category_groups

  has_one :recruiter
  has_one :country
  has_one :billing_currency
end
