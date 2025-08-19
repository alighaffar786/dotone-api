class Campaign < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include ModelCacheable
  include NameHelper
  include Relations::AffiliateStatAssociated
  include Relations::ChannelAssociated

  CAMPAIGN_TYPES = ['CPM', 'CPC/PPC', 'Pre-Paid']

  has_many_affiliate_stats
  has_many :affiliates, inverse_of: :campaign, dependent: :nullify
  has_many :networks, inverse_of: :campaign, dependent: :nullify

  validates :name, presence: true
  validates :campaign_type, inclusion: { in: CAMPAIGN_TYPES, allow_blank: true }

  define_constant_methods CAMPAIGN_TYPES, :campaign_type

  scope :like, -> (*args) {
    if args[0].present?
      left_outer_joins(:channel).where('campaigns.id LIKE :q OR campaigns.name LIKE :q OR channels.name LIKE :q', q: "%#{args[0]}%")
    end
  }

  # Method to convert this campaign into
  # a vanity tracking URL that is currently used
  # to run internal campaign
  def to_tracking_url(extra_parameters = {})
    return if destination_url.blank?

    uri = DotOne::Utils::Url.parse(destination_url)
    return if uri&.host.blank?

    uri.path = "/r/#{id}"

    query = uri.query_values || {}
    query = query.merge(extra_parameters)

    uri.query_values = query if query.present?
    uri.host = 'www.affiliates.one' if uri.host.match(/^(adv|pub)\.affiliates\.one$/)

    uri.to_s
  end
end
