class AffiliateApplication < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include HasKeywords
  include LocalTimeZone
  include Traceable

  STATUSES = ['Approved', 'Suspended', 'Brand New']
  TIME_TO_CALLS = ['Anytime', 'Morning', 'Afternoon', 'Evening']

  belongs_to :affiliate, inverse_of: :affiliate_application, touch: true

  # validates :affiliate_id, uniqueness: true
  # validates :time_to_call, inclusion: { in: TIME_TO_CALLS, allow_blank: true }

  before_validation :set_defaults
  after_save :update_url_to_affiliate_keywords

  set_local_time_attributes :created_at, :accept_terms_at, :age_confirmed_at
  define_constant_methods STATUSES, :status
  define_constant_methods TIME_TO_CALLS, :time_to_call

  private

  def update_url_to_affiliate_keywords
    save_url_as_keywords(company_site_was, company_site)
  end

  def set_defaults
    self.status ||= AffiliateApplication.status_brand_new
    self.age_confirmed_at ||= Time.now if age_confirmed_changed? && age_confirmed?
    self.accept_terms_at ||= Time.now if accept_terms_changed? && accept_terms?
  end
end
