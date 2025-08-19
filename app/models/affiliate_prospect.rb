class AffiliateProspect < DatabaseRecords::PrimaryRecord
  self.table_name = 'publisher_prospects'

  include Scopeable
  include AffiliateLoggable
  include Relations::CountryAssociated

  belongs_to :recruiter, class_name: 'AffiliateUser', foreign_key: :recruiter_id, inverse_of: :affiliate_prospects
  belongs_to :affiliate, inverse_of: :affiliate_prospect, optional: true

  has_one :site_info, inverse_of: :affiliate_prospect

  has_many :affiliate_prospect_categories, inverse_of: :affiliate_prospect, dependent: :destroy
  has_many :categories, through: :affiliate_prospect_categories

  validates :email, presence: true, uniqueness: true, format: { with: REGEX_EMAIL }
  validates_associated :site_info

  accepts_nested_attributes_for :site_info

  after_validation :assign_affiliate
  after_validation :set_site_info_live
  after_destroy :destroy_site_info

  scope_by_recruiter
  scope_by_affiliate

  scope :like, -> (*args) {
    if args[0].present?
      left_joins(:affiliate, :site_info)
        .where(
          'publisher_prospects.email LIKE :q OR site_infos.username LIKE :q OR site_infos.url LIKE :q OR affiliates.id LIKE :q  OR affiliates.first_name LIKE :q OR affiliates.last_name LIKE :q',
          q: "%#{args[0]}%",
        )
    end
  }

  private

  def assign_affiliate
    self.affiliate_id ||= Affiliate.find_by(email: email)&.id
  end

  def set_site_info_live
    return if affiliate.blank?

    if (existing_site_info = affiliate.site_infos.find_by(url: site_info.url))
      ignore_attributes = ['id', 'created_at', 'updated_at']
      new_attributes = site_info.attributes.except(*ignore_attributes)
        .merge(existing_site_info.attributes.except(*ignore_attributes))
      existing_site_info.assign_attributes(new_attributes)
      self.site_info = existing_site_info
    end
  end

  def destroy_site_info
    if site_info.affiliate_id?
      site_info.update_column(:affiliate_prospect_id, nil)
    else
      site_info.destroy
    end
  end
end
