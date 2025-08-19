class ContactList < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include NameHelper
  include Owned
  include Relations::HasCrmInfos

  STATUSES = ['Active', 'Archived'].freeze

  MESSENGER_SERVICES = [
    'Line',
    'QQ',
    'Skype',
    'Telegram',
    'WeChat',
    'Whatsapp',
  ].freeze

  belongs_to_owner touch: true

  validates :first_name, :last_name, :phone, presence: true
  validates :email, presence: true,
    uniqueness: { scope: [:owner_type, :owner_id], case_sensitive: false },
    format: { with: REGEX_EMAIL }
  validates :status, inclusion: { in: STATUSES }
  validates :messenger_service, inclusion: { in: MESSENGER_SERVICES, allow_blank: true }

  before_validation :set_default_status, on: :create

  define_constant_methods STATUSES, :status

  scope :email_optin, -> { where(email_optin: true) }

  def locale
    @locale ||= if owner && owner.respond_to?(:locale)
      owner.locale
    else
      Language.platform_locale
    end
  end

  def mark_active!
    self.status = ContactList.status_active
    save!
  end

  def mark_archived!
    self.status = ContactList.status_archived
    save!
  end

  private

  def set_default_status
    self.status ||= ContactList.status_active
  end
end
