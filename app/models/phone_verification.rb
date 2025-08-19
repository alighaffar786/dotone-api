class PhoneVerification < DatabaseRecords::PrimaryRecord
  OTP_EXPIRATION_TIME = 10.minutes
  OTP_MAX_RESEND_TIME = 1.minute
  MAX_DAY_RESEND = 1
  MAX_RESEND = 5

  attr_accessor :should_send_sms

  belongs_to :owner, polymorphic: true

  validates :phone_number, presence: true, format: { with: /\A\+\d{1,15}\z/, message: :invalid_format }
  validates :phone_number, uniqueness: { scope: [:owner_id, :owner_type] }
  validate :check_can_resend, on: :update

  before_validation :sanitize_phone_number
  before_create :generate_otp
  after_update :cleanup_unused
  after_save :update_owner, if: :verified_at?
  after_save :send_otp, if: :should_send_sms

  def verify(value)
    if value == otp && !otp_expired?
      update(verified_at: Time.now)
    else
      errors.add(:otp, :not_match)
      false
    end
  end

  def self.sanitize_phone_number(value)
    value.to_s.gsub(/[^+\d]/, '')
  end

  def max_attempt_reached?
    attempts > MAX_RESEND
  end

  def otp_expired?
    expired_at < Time.current
  end

  def resend_in_limit?
    updated_at > (Time.now - OTP_MAX_RESEND_TIME)
  end

  def create_or_resend
    if new_record?
      save
    elsif !max_attempt_reached? && (updated_at + MAX_DAY_RESEND.day) > Time.current
      resend_otp
    elsif max_attempt_reached? && (updated_at + MAX_DAY_RESEND.day) < Time.current
      reset_attemps_and_resend
    else
      errors.add(:otp, :max_attempt_reached)
      false
    end
  end

  def resend_otp
    generate_otp
    self.attempts += 1
    save
  end

  def reset_attemps_and_resend
    generate_otp
    self.attemps = 0
    save
  end

  def send_otp
    if Rails.env.production?
      client = Aws::SNS::Client.new
      client.publish(
        phone_number: phone_number,
        message: "Your verification code is: #{otp}",
      )
    end

    true
  end

  private

  def update_owner
    if owner_type == 'Affiliate'
      owner.affiliate_application.update(phone_number: phone_number)
    end
  end

  def check_can_resend
    return unless should_send_sms

    errors.add(:otp, :max_attempt_reached) if max_attempt_reached?
    errors.add(:otp, :limit_in_resend) if resend_in_limit?
  end

  def generate_otp
    self.should_send_sms = true
    self.otp = rand(100000..999999).to_s
    self.expired_at = Time.current + OTP_EXPIRATION_TIME
  end

  def sanitize_phone_number
    self.phone_number = PhoneVerification.sanitize_phone_number(phone_number)
  end

  def cleanup_unused
    return unless verified_at_previously_changed? && verified_at_previously_was.nil? && verified_at?

    PhoneVerification.where(owner: owner).where.not(id: id).destroy_all
  end
end
