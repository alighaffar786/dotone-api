class Newsletter < DatabaseRecords::PrimaryRecord
  include AppRoleable
  include ConstantProcessor
  include Scopeable

  STATUSES = [
    'New',
    'Sending',
    'Delivered',
    'Error',
  ].freeze

  RECIPIENTS = {
    affiliate: ['all', 'all managed', 'campaign-affiliates'],
    advertiser: ['all', 'all managed', 'all managed live'],
  }.freeze

  alias_attribute :offer_id, :offer_list

  belongs_to :logo, -> { where(used_for: 'Newsletter') }, class_name: 'CkImage', inverse_of: :newsletters
  belongs_to :offer, foreign_key: :offer_list, inverse_of: :newsletters

  has_one :email_template, as: :owner, inverse_of: :owner, dependent: :destroy

  accepts_nested_attributes_for :email_template

  before_validation :set_defaults
  before_save :set_recipient_ids, if: :delivered?

  serialize :offer_list
  serialize :recipients

  define_constant_methods STATUSES, :status

  scope_by_status

  scope :like, -> (*args) { where('newsletters.sender LIKE ?', "%#{args[0]}%") if args[0].present? }

  def self.predefined_recipients
    RECIPIENTS.values.flatten
  end

  def self.restructure_attributes
    Newsletter.where(role: nil).find_each do |newsletter|
      newsletter.update(
        role: newsletter.recipient_type,
        sender_id: newsletter.sender&.id,
        recipient: newsletter.recipient,
        recipient_ids: newsletter.recipient_ids,
      )
    end
  end

  def system?
    [DotOne::Setup.general_contact_email, 'system'].compact.include?(self[:sender])
  end

  def recipient_type
    return role if role.present?
    return @recipient_type if @recipient_type.present?

    @recipient_type = recipients&.keys&.first
    @recipient_type = 'network' if @recipient_type == 'advertiser'
    @recipient_type
  end

  def recipient
    return self[:recipient] if self[:recipient].present?
    return if recipient_type.blank?
    return @recipient if @recipient.present?

    @recipient = recipients[recipient_type] if recipients.present?
    @recipient = 'all' if @recipient == 'all managed'
    @recipient
  end

  def sender
    if system?
      AffiliateUser.new(
        roles: 'Admin',
        email: DotOne::Setup.general_contact_email,
        first_name: DotOne::Setup.wl_name,
      )
    elsif sender_id.present?
      AffiliateUser.find_by(id: sender_id)
    end
  end

  def recipient_ids
    return @recipient_ids if @recipient_ids.present?

    @recipient_ids = self[:recipient_ids] if self[:recipient_ids].present?

    @recipient_ids ||= if Newsletter.predefined_recipients.include?(recipient)
      []
    else
      recipient.to_s.split(',')
    end
  end

  def recipient_klass
    @recipient_klass ||= role.classify.constantize
  end

  def recipient_list
    return recipient_klass.where(id: self[:recipient_ids]).preload(:contact_lists) if self[:recipient_ids].present?
    return recipient_klass.where(id: -1) unless sender

    ability = Ability.new(sender)

    result = case role.to_sym
      when :affiliate
        case recipient
        when 'all'
          Affiliate.active
        when 'campaign-affiliates'
          offer.active_affiliates.where(optout_from_offer_newsletter: false)
        else
          Affiliate.active.where(id: recipient_ids)
        end
      when :network
        case recipient
        when 'all'
          Network.active
        when 'all managed live'
          Network.active.where(id: NetworkOffer.active.select(:network_id))
        else
          Network.active.where(id: recipient_ids)
        end
      end

    result.accessible_by(ability).preload(:contact_lists)
  end

  def deliver
    return unless new?

    # Check if there is any recipients to send this email to.
    if recipient_list.none?
      update(status: Newsletter.status_error, error_reason: 'No active recipients')
    else
      update(status: Newsletter.status_sending, start_sending_at: DateTime.now)

      recipient_list.find_each do |recipient|
        NewsletterMailer.email_message(self, recipient).deliver_later
      end

      update(status: Newsletter.status_delivered, end_sending_at: DateTime.now)
    end
  end

  private

  def set_defaults
    self.status ||= Newsletter.status_new
  end

  def set_recipient_ids
    self.recipient_ids = recipient_list.ids
  end
end
