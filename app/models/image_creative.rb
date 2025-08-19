class ImageCreative < DatabaseRecords::PrimaryRecord
  include Attacheable
  include BecomeCreative
  include PurgeableFile

  has_many_affiliate_stats
  has_many :image_creative_stats, inverse_of: :image_creative, dependent: :destroy
  has_many :ad_slots, through: :affiliates
  has_many :category_groups, through: :offers

  validates :cdn_url, presence: true, on: :create

  before_save :adjust_values
  after_save :refresh_offer_thumbnail

  # These callbacks need to be after the mount uploader callbacks
  # when it actually uploads the image to CDN. Otherwise,
  # it will cache temporary location instead and making it undeliverable
  # in production
  after_save :cache_for_delivery
  after_destroy :flush_cache_for_delivery

  mount_uploader :image, ImageUploader

  set_local_time_attributes :active_date_start, :active_date_end, :created_at, :updated_at
  set_purgeable_file_attributes :cdn_url
  set_instance_cache_methods :alternative

  ##
  # Generating image_data, image_filename, download_image
  attachment_attrs :image

  scope :with_size, -> (*args) { where(size: args) if args.present? }
  scope :publicly, -> { where.not(internal: true) }
  scope :internally, -> { where(internal: true) }
  scope :publishable, -> {
    right_now = Time.now
    where('is_infinity_time IS NULL OR is_infinity_time = 1 OR (active_date_start <= ? AND active_date_end >= ?)', right_now, right_now)
  }

  def self.allowed_file_types
    ['jpg', 'jpeg', 'gif', 'png', 'ico']
  end

  def self.inventories(affiliate_ids: [], category_group_ids: [], sizes: [])
    return [] if affiliate_ids.blank? || category_group_ids.blank?

    sql = <<-SQL.squish
      SELECT DISTINCT `image_creatives`.id AS creative_id,#{' '}
        `affiliate_offers`.affiliate_id AS affiliate_id,
        `category_groups`.id AS category_group_id,
        `affiliate_offers`.id AS campaign_id
      FROM `image_creatives`#{' '}
        INNER JOIN `creatives` ON `creatives`.`entity_id` = `image_creatives`.`id`#{' '}
          AND `creatives`.`entity_type` = 'ImageCreative'#{' '}
        INNER JOIN `offer_variants` ON `offer_variants`.`id` = `creatives`.`offer_variant_id`#{' '}
        INNER JOIN `affiliate_offers` ON `affiliate_offers`.`offer_variant_id` = `offer_variants`.`id`#{' '}
        LEFT OUTER JOIN `offer_categories` ON `offer_categories`.offer_id = `offer_variants`.offer_id
        LEFT OUTER JOIN categories ON categories.id = offer_categories.category_id#{' '}
        LEFT OUTER JOIN category_groups ON category_groups.id = categories.category_group_id#{' '}
      WHERE (offer_variants.status IN ('Active Public','Active Private'))#{' '}
        AND (affiliate_offers.affiliate_id IN (?))
        AND (category_groups.id IN (?))
        AND (affiliate_offers.approval_status = 'Active')#{' '}
        AND (is_infinity_time IS NULL#{' '}
          OR is_infinity_time = 1#{' '}
          OR (active_date_start <= ? AND active_date_end >= ?))#{' '}
        AND (image_creatives.status = 'Active')
        AND (image_creatives.size IN (?))
    SQL

    sql = sanitize_sql([
      sql,
      affiliate_ids,
      category_group_ids,
      Time.now, Time.now,
      sizes
    ])

    TextCreative.connection.select_all(sql)
  end

  def self.delivery_cache_key(id)
    DotOne::Utils.to_cache_key(ImageCreative, 'ImageCreative', id, :delivery)
  end

  def self.cached_delivery(id)
    DotOne::Cache.fetch(ImageCreative.delivery_cache_key(id)) do
      ImageCreative.cached_find(id)&.cache_for_delivery&.dig(:data_load)
    end
  end

  def self.send_rejected_notification(banners)
    [banners].flatten.group_by(&:network).each do |network, image_creatives|
      AdvertiserMailer.banner_creative_rejected(network, image_creatives, cc: true).deliver_later
    end
  end

  def cdn_url
    self[:cdn_url].presence || image&.url
  end

  def name
    if client_url.present?
      'Default'
    else
      size
    end
  end

  def name_to_trace
    return unless offer_variant

    "(CREATIVE: #{name}) (OFFER VARIANT: #{offer_variant.id_with_name}) (OFFER: #{offer.id_with_name})"
  end

  def presentable_to_affiliate?
    !internal? && active?
  end

  def publishable?
    if active? && (offer_variant&.active? || offer&.active?)
      return true if is_infinity_time.blank? && active_date_start.blank? && active_date_end.blank?

      right_now = Time.now
      active_start_at = (active_date_start || (Time.now - 99.years))
      active_end_at = (active_date_end || (Time.now + 99.years))

      is_infinity_time? || (right_now >= active_start_at && right_now <= active_end_at)
    else
      false
    end
  end

  def alternative
    return unless default_variant = offer_variants.default.first
    return unless default_variant.active?

    default_variant
      .image_creatives
      .with_size(size)
      .where.not(id: id)
      .publicly
      .publishable
      .active
      .first
  end

  def prepare_for_delivery
    if offer_variant&.active? || offer&.active?
      data_load = DotOne::Services::ImpressionDataLoad.new(self)
      data_load.add_offer_variant(offer_variant)
      data_load
    end
  end

  def cache_for_delivery
    to_return = {
      data_load: nil,
      status: nil,
    }

    ckey = ImageCreative.delivery_cache_key(id)

    if present? && publishable?
      data_load = prepare_for_delivery

      Rails.cache.write(ckey, data_load, expires_in: 99.days)

      to_return = {
        data_load: data_load,
        status: 'Self Ready',
      }
    elsif present?
      alternative = cached_alternative
      if alternative.blank?
        to_return[:status] = 'Alternative Blank'
      else
        data_load = alternative.prepare_for_delivery
        Rails.cache.write(ckey, data_load, expires_in: 99.days )
        to_return = {
          data_load: data_load,
          status: 'Alternative Ready',
        }
      end
    else
      to_return = {
        data_load: nil,
        status: 'Self Blank',
      }
    end

    to_return
  end

  def to_token_params(affiliate, catch_any: false)
    return unless affiliate_offer = offer.active_affiliate_offer_for(affiliate, catch_any: catch_any)

    affiliate_offer.to_token_params.merge(image_creative_id: id)
  end

  def to_tracking_url(affiliate, catch_any: false)
    return unless token_params = to_token_params(affiliate, catch_any: catch_any)

    cached_offer_variant.to_tracking_url(
      token_params: token_params,
      extra_params: { t: client_url },
    )
  end

  def to_impression_url(affiliate, catch_any: false)
    return unless affiliate_offer = offer.active_affiliate_offer_for(affiliate, catch_any: catch_any)

    token = DotOne::Track::Token.new(
      affiliate_id: affiliate_offer.affiliate_id,
      affiliate_offer_id: affiliate_offer.id,
      offer_variant_id: offer_variant.id,
      image_creative_id: id,
    )

    DotOne::Track::Routes.track_impression_image_url(
      id: id,
      token: token.encrypted_string,
    )
  end

  def record_ui_download!
    image_creative_stats
      .first_or_initialize(date: DateTime.now.utc.to_date)
      .record_ui_download!
  end

  def client_url
    return unless offer_variant&.deeplinkable?

    self[:client_url].presence || offer_variant.destination_url.presence || offer.destination_url.presence
  end

  private

  def adjust_values
    self.size = "#{width}x#{height}" if width_changed? || height_changed?
  end

  # TODO: delete
  def refresh_offer_thumbnail
    offer&.touch if reload && client_url.blank?
  end

  def flush_cache_for_delivery
    Rails.cache.delete(ImageCreative.delivery_cache_key(id))
  end
end
