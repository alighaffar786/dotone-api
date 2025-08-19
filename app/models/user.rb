class User < DatabaseRecords::SecondaryRecord
  include HasBlogAuthor
  include NameHelper
  include Traceable
  include Relations::CurrencyAssociated
  include Relations::HasChannels
  include Relations::TimeZoneAssociated

  has_many :blog_contents, as: :author, inverse_of: :author, dependent: :nullify
  has_many :quicklinks, as: :owner, inverse_of: :owner, dependent: :destroy
  has_many :affiliate_logs, as: :agent, inverse_of: :agent, dependent: :nullify

  has_one :wl_company, inverse_of: :user, dependent: :destroy

  accepts_nested_attributes_for :wl_company

  attr_accessor :avatar_cdn_url

  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 5 }, confirmation: true, allow_blank: true
  validates :email, presence: true, uniqueness: { scope: :login_domain }, format: { with: REGEX_EMAIL }

  mount_uploader :avatar, AvatarUploader

  serialize :setup

  trace_ignorable :perishable_token, :last_request_at

  acts_as_authentic do |config|
    # config.validate_login_field = false
    config.transition_from_crypto_providers = [Authlogic::CryptoProviders::Sha512]
    config.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  def activate!
    self.active = true
    save
  end

  def active?
    active
  end

  def deactivate!
    self.active = false
    save
  end

  def deliver_activation_confirmation!
    reset_perishable_token!
    UserMailer.activation_confirmation(self).deliver_later
  end

  def deliver_activation_instructions!
    reset_perishable_token!
    UserMailer.activation_instructions(self).deliver_later
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.password_reset_instructions(self).deliver_later
  end

  def name
    username
  end

  def registered_as?(args)
    if args.is_a?(String)
      roles.include?(Role.find_by_name(args)) rescue false
    elsif args.is_a?(Array)
      args.each do |a|
        return true if registered_as?(a)
      end
      false
    end
  end

  def revoke_role(role_name)
    role = Role.find_by_name(role_name)
    return false unless roles.include?(role)

    roles.delete(role)
    reload
    true
  end

  def traffic_stat_table_name
    "traffic_stats_#{id}"
  end

  def is_media_buyer
    wl_company.plan.name.include?('Media Buyer')
  end
end
