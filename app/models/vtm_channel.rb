class VtmChannel < DatabaseRecords::PrimaryRecord
  include NameHelper
  include Relations::AffiliateAssociated
  include Relations::NetworkAssociated
  include Relations::OfferAssociated

  NAME_ORGANIC_TRAFFIC = 'Organic Traffic'.freeze

  belongs_to :mkt_site, inverse_of: :vtm_channels, touch: true

  has_many :vtm_pixels, inverse_of: :vtm_channel, dependent: :destroy

  scope :network_channels, -> { where(name: DotOne::Setup.wl_setup(:network_channel_name)) }
  scope :organic_channels, -> { where(name: NAME_ORGANIC_TRAFFIC) }

  accepts_nested_attributes_for :vtm_pixels, reject_if: -> (attrs) { attrs['step_name'].blank? }, allow_destroy: true

  validates :name, presence: true
  validates :name, uniqueness: { scope: :affiliate_id }, unless: :network_id?
  validates :name, uniqueness: { scope: [:network_id, :mkt_site_id] }, unless: :affiliate_id?

  def self.network_channel_available?
    DotOne::Setup.wl_setup(:network_channel_name).present?
  end

  def organic?
    name.to_s.downcase == NAME_ORGANIC_TRAFFIC.downcase
  end

  def this_network?
    name.to_s.downcase == DotOne::Setup.wl_setup(:network_channel_name).to_s.downcase
  end
end
