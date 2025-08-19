class ClickAbuseReport < DatabaseRecords::PrimaryRecord
  AGGREGATE_COLUMNS = [:ip_address, :error_details, :referer, :token].freeze

  scope :like, -> (*args) {
    where('token LIKE :q or referer LIKE :q or error_details LIKE :q OR ip_address LIKE :q OR user_agent LIKE :q', q: "%#{args[0]}%") if args[0].present?
  }

  validates :error_details, uniqueness: { scope: :token }

  scope :blocked, -> { where(blocked: true) }
  scope :unblocked, -> { where(blocked: false) }

  def token_item
    @token_item ||= DotOne::Track::Token.new(token)
  end

  def affiliate_id
    token_item&.affiliate_id
  end

  def offer_variant_id
    token_item&.offer_variant_id
  end

  def affiliate_offer
    @affiliate_offer = if token_item&.affiliate_offer_id.present?
      AffiliateOffer.find_by(id: token_item.affiliate_offer_id)
    elsif token_item&.affiliate_id.present? && token_item&.offer_variant_id.present?
      offer_variant = OfferVariant.find_by(id: token_item.offer_variant_id)
      AffiliateOffer.find_by(affiliate_id: token_item.affiliate_id, offer_id: offer_variant&.offer_id)
    end
  end

  def self.build_cache_key(date)
    "ClickAbuseReport-Clicks-#{date}"
  end

  def self.block_cache_key
    build_cache_key(Date.today.to_s)
  end

  def self.key_date_range
    (Date.parse('2025-05-24')..Date.today).to_a.map(&:to_s)
  end

  def self.cache_keys
    ['ClickAbuseReport-Clicks', *(key_date_range.map { |k| build_cache_key(k) })]
  end

  def self.block_list
    cache_keys.flat_map { |key| DotOne::Cache.fetch(key).to_a }
  end

  def self.current_list
    DotOne::Cache.fetch(block_cache_key)
  end

  def self.check_blocked?(*args)
    (block_list & args.map(&:to_s).map(&:downcase)).present?
  end

  def self.block(value)
    new_list = (current_list | [value.to_s.downcase]).compact_blank.uniq
    Rails.cache.write(block_cache_key, new_list, expires_in: 99.years)
  end

  def self.empty_block_list(date)
    Rails.cache.delete(build_cache_key(date))
  end

  def block_by_token
    if affiliate_offer
      affiliate_offer.refresh_track_token!
    end

    self.class.block(token)
    self.class.where(token: token).update_all(blocked: true)
  end

  def block_by_referer
    self.class.block(referer)
    self.class.where(referer: referer).update_all(blocked: true)
  end

  def block_by_ip_address
    self.class.block(ip_address)
    self.class.where(ip_address: ip_address).update_all(blocked: true)
  end

  def block_by_error_details
    self.class.block(error_details)
    self.class.where(error_details: error_details).update_all(blocked: true)
  end

  def self.top_aggregations(column)
    return [] unless AGGREGATE_COLUMNS.include?(column.to_sym)

    unblocked
      .where.not(column => nil)
      .select("#{column}, SUM(count) AS total_count")
      .group(column)
      .order(total_count: :desc)
      .limit(10)
      .map { |record| { value: record.send(column), count: record.total_count.to_i } }
  end
end
