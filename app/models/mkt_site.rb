class MktSite < DatabaseRecords::PrimaryRecord
  include NameHelper
  include ModelCacheable
  include Relations::AffiliateAssociated
  include Relations::AffiliateStatAssociated
  include Relations::NetworkAssociated
  include Relations::OfferAssociated

  PLATFORMS = ['shopify', 'easystore']

  alias_attribute :name, :domain

  has_many_affiliate_stats
  has_many :vtm_channels, inverse_of: :mkt_site, dependent: :destroy

  has_one :network_channel, -> { network_channels }, class_name: 'VtmChannel', autosave: true
  has_one :organic_channel, -> { organic_channels }, class_name: 'VtmChannel', autosave: true

  validates :domain, presence: true
  validates :network_id, uniqueness: { scope: :offer_id, allow_blank: true  }
  validates :affiliate_id, uniqueness: { scope: :offer_id, allow_blank: true  }
  validates :platform, inclusion: { in: PLATFORMS }, allow_blank: true

  before_create :build_channels
  before_save :adjust_values
  before_save :reflect_network_channel

  scope :like, -> (*args) {
    where('id LIKE :q OR domain LIKE :q', q: "%#{args[0]}%") if args[0].present?
  }

  def self.cached_find_by_accepted_domains(domain)
    found = cached_domains_map[domain.to_s.downcase]
    cached_find(found) if found.present?
  end

  def self.cached_find_by_offer_id(offer_id)
    found = cached_offers_map[offer_id.to_s]
    cached_find(found) if found.present?
  end

  def self.cached_domains_map
    DotOne::Cache.fetch("MKTSITE_DOMAINS_#{MktSite.cached_max_updated_at}") do
      MktSite.pluck(:id, :domain, :accepted_origins).reduce({}) do |collection, mkt_site|
        id, domain, accepted_origins = mkt_site
        domains = [domain, *accepted_origins].compact_blank.map(&:downcase)
        domains.each { |d| collection[d] = id }
        collection
      end
    end
  end

  def self.cached_offers_map
    DotOne::Cache.fetch("MKTSITE_OFFERS_#{MktSite.cached_max_updated_at}") do
      MktSite
        .where.not(offer_id: nil)
        .pluck(:id, :offer_id)
        .reduce({}) do |collection, mkt_site|
          id, offer_id = mkt_site
          collection[offer_id.to_s] = id
          collection
        end
    end
  end

  def pixels(options = {})
    ckey = DotOne::Utils.to_global_cache_key(self, options)

    Rails.cache.fetch(ckey) do
      channel = if options[:vtm_channel].present?
        vtm_channels.find_by_name(options[:vtm_channel])
      else
        vtm_channels.find_by_name(VtmChannel::NAME_ORGANIC_TRAFFIC)
      end

      pxs = []

      return pxs if channel.blank?

      if BooleanHelper.truthy?(options[:conversions])
        if options[:step].present?
          vtm_pixel = channel.vtm_pixels.find_by_step_name(options[:step])
          pxs << vtm_pixel.order_conv_pixel if vtm_pixel.present?
        else
          pxs << channel.conv_pixel
        end
      else
        pxs << channel.visit_pixel
      end

      pxs
    end
  end

  def site_code(options = {})
    if options[:conversions]
      case platform
      when 'shopify'
        return DotOne::ScriptGenerator.generate_shopify_pixel(id)
      when 'easystore'
        return DotOne::ScriptGenerator.generate_easystore_pixel(id)
      end
    end

    DotOne::ScriptGenerator.generate_conversion_pixel_script(id, options)
  end

  def verify_domain(origin)
    origin_host = URI.parse(origin).host

    return unless [domain, *accepted_origins].compact_blank.include?(origin_host)

    update(verified: true)
  rescue URI::InvalidURIError
    false
  end

  def normalized_accepted_origins
    accepted_origins
      .to_a
      .map { |origin| DotOne::Utils::Url.host_name(origin) }
      .reject(&:blank?)
      .uniq
  end

  private

  def build_channels
    return if network_id.blank?

    # This needs to create a default channel for advertisers only
    build_organic_channel(network_id: network_id)

    # If defined, we setup default network channel also. This is channel
    # that will be used to advertise via this network
    return unless VtmChannel.network_channel_available?

    build_network_channel(network_id: network_id, offer_id: offer_id)
  end

  def adjust_values
    self.accepted_origins = normalized_accepted_origins
    self.network_id = offer&.network_id if affiliate_id.blank? && offer_id.present?
  end

  def reflect_network_channel
    return if network_channel.blank?

    self.network_channel.offer_id = offer_id
    self.network_channel.network_id = network_id
    self.organic_channel.network_id = network_id
  end
end
