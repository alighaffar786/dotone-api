class Teams::Affiliate::SearchSerializer < Base::AffiliateSerializer
  attributes :id

  conditional_attributes :status, :created_at, :gender, :birthday, :email, :messenger_service, :messenger_service_2,
    :messenger_id, :messenger_id_2, :source, if: :full?

  has_one :country, if: :full?
  has_one :affiliate_application, if: :full?

  def full?
    can_read_affiliate? && full_scope_requested?
  end
end
