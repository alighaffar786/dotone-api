class AffiliateUser < DatabaseRecords::PrimaryRecord
  include Authenticatable
  include BecomeChatter
  include ConstantProcessor
  include HasBlogAuthor
  include HasUniqueToken
  include NameHelper
  include Roleable
  include Traceable
  include PurgeableFile
  include Relations::CurrencyAssociated
  include Relations::HasChannels
  include Relations::HasDownloads
  include Relations::HasUploads
  include Relations::LanguageAssociated
  include Relations::TimeZoneAssociated

  ROLES = [
    'Admin',
    'Network Manager',
    'Affiliate Director',
    'Affiliate Manager',
    'Sales Director',
    'Sales Manager',
    'Designer',
    'Ops Team',
    'Event Director',
    'Event Manager',
  ].freeze

  STATUSES = ['Active', 'Suspended']

  has_many :affiliate_assignments, -> { affiliate }, inverse_of: :affiliate_user, dependent: :destroy
  has_many :affiliates, through: :affiliate_assignments
  # TODO: fix polymorphic
  # has_many :attachments, as: :uploader, inverse_of: :uploader, dependent: :nullify
  has_many :network_assignments, -> { network }, class_name: 'AffiliateAssignment', inverse_of: :affiliate_user, dependent: :destroy
  has_many :networks, through: :network_assignments
  has_many :offers, through: :networks
  has_many :offer_variants, through: :offers
  has_many :member_relations, foreign_key: :manager_id, class_name: 'WlaRelation', inverse_of: :manager, dependent: :destroy
  has_many :manager_relations, foreign_key: :member_id, class_name: 'WlaRelation', inverse_of: :member, dependent: :destroy
  has_many :members, through: :member_relations
  has_many :managers, through: :manager_relations
  has_many :quicklinks, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :affiliate_logs, as: :agent, inverse_of: :agent, dependent: :nullify
  has_many :blog_contents, as: :author, inverse_of: :author, dependent: :nullify
  has_many :recruits, class_name: 'Affiliate', foreign_key: :recruiter_id, inverse_of: :recruiter, dependent: :nullify
  has_many :email_opt_ins, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :affiliate_prospects, foreign_key: :recruiter_id, inverse_of: :recruiter, dependent: :nullify
  has_many :recruited_networks, class_name: 'Network', foreign_key: :recruiter_id, inverse_of: :recruiter

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: REGEX_EMAIL }
  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }, format: { with: REGEX_USERNAME, multiline: true }
  validates :last_name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :roles, presence: true, inclusion: { in: ROLES }

  before_save :cleanup_relations

  # TODO:: deprecate
  # TODO:: delete
  mount_uploader :avatar, AvatarUploader

  serialize :setup
  define_constant_methods ROLES, :roles
  define_constant_methods STATUSES, :status
  trace_ignorable :unique_token
  set_purgeable_file_attributes :avatar_cdn_url

  authenticatable do |user|
    user if user && user.active?
  end

  scope :directors, -> { where(roles: director_roles) }
  scope :managers, -> { where(roles: manager_roles) }
  scope :sales_team, -> { where(roles: sales_team_roles) }
  scope :with_emails, -> (*args) { where(email: args[0]) if args[0].present? }

  def self.upper_level_roles
    [roles_admin, roles_network_manager, roles_ops_team]
  end

  def self.event_team_roles
    [roles_event_director, roles_event_manager]
  end

  def self.affiliate_team_roles
    [roles_affiliate_director, roles_affiliate_manager, *event_team_roles]
  end

  def self.sales_team_roles
    [roles_sales_director, roles_sales_manager]
  end

  def self.director_roles
    [roles_affiliate_director, roles_sales_director, roles_event_director]
  end

  def self.manager_roles
    [roles_affiliate_manager, roles_sales_manager, roles_event_manager]
  end

  def self.managed_affiliate_ids
    where(roles: [*affiliate_team_roles, roles_network_manager, roles_ops_team])
      .flat_map { |user| user.affiliate_ids }
      .uniq
  end

  def self.managed_network_ids
    where(roles: [*sales_team_roles, roles_network_manager, roles_ops_team])
      .flat_map { |user| user.network_ids }
      .uniq
  end

  def self.recruited_affiliate_ids
    Affiliate.where(recruiter_id: ids).ids
  end

  def self.recruited_network_ids
    Network.where(recruiter_id: ids).ids
  end

  def upper_team?
    AffiliateUser.upper_level_roles.include?(roles)
  end

  def affiliate_team?
    AffiliateUser.affiliate_team_roles.include?(roles)
  end

  def event_team?
    AffiliateUser.event_team_roles.include?(roles)
  end

  def sales_team?
    AffiliateUser.sales_team_roles.include?(roles)
  end

  def director?
    AffiliateUser.director_roles.include?(roles)
  end

  def manager?
    AffiliateUser.manager_roles.include?(roles)
  end

  def full_name
    super.presence || username
  end

  private

  def cleanup_relations
    # clear blank ids from the relations
    manager_relations.to_a.reject! { |x| x.manager_id.blank? }
    member_relations.to_a.reject! { |x| x.member_id.blank? }

    # clear manager relations if it is no longer necessary
    self.manager_ids = nil unless affiliate_manager?

    # clear member relations if it is no longer necessary
    self.member_ids = nil unless affiliate_director?
  end
end
