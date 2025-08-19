class Teams::Network::SearchSerializer < Base::NetworkSerializer
  attributes :id

  conditional_attributes :name, :billing_currency_id, :contact_email, :name, :contact_name, :contact_phone, :contact_title,
    :status, :sales_pipeline, if: :can_read_network?

  conditional_attributes :brands, :created_at, :company_url, :grade, :published_date, :profile_updated_at, if: :full?

  has_many :affiliate_users, if: :full?
  has_many :category_groups, if: :full?
  has_many :contact_lists, if: :full?

  has_one :country, if: :full?
  has_one :recruiter, if: :full?

  def full?
    can_read_network? && full_scope_requested?
  end
end
