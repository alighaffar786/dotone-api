require 'securerandom'

class ApiKey < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include LocalTimeZone
  include Owned

  TYPES = ['AccessToken']
  STATUSES = ['Active', 'Inactive']

  MAX_ALLOWED = 2

  belongs_to :partner_app, inverse_of: :api_keys

  validates :status, inclusion: { in: STATUSES }
  validates :type, inclusion: { in: TYPES, allow_blank: true }
  validates_with ApiKeyHelpers::Validator::ApiKeyValidator, on: :create, unless: :access_token?

  before_create :set_defaults

  define_constant_methods STATUSES, :status
  set_local_time_attributes :created_at, :last_used_at

  scope :api_keys, -> { where(type: nil) }
  scope :access_tokens, -> { where(type: 'AccessToken') }

  def access_token?
    type == 'AccessToken'
  end

  def refresh_last_used_at!
    self.last_used_at = Time.now
    save!
  end

  def current_count
    @current_count ||= ApiKey.where.not(id: id)
      .where(owner_id: owner_id, owner_type: owner_type, type: type)
      .count
  end

  private

  def set_defaults
    self.value = DotOne::Utils.generate_token
    self.secret_key = SecureRandom.urlsafe_base64
  end
end
