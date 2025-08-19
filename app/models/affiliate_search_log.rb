class AffiliateSearchLog < DatabaseRecords::PrimaryRecord
  include Relations::AffiliateAssociated

  validates :affiliate_id, :date, presence: true
  validates :offer_keyword, uniqueness: { scope: [:affiliate_id, :date] }, if: :offer_keyword?
  validates :product_keyword, uniqueness: { scope: [:affiliate_id, :date] }, if: :product_keyword?

  scope :between, -> (range) { where(date: range) if range.present? }
  scope :for_offer, -> { where.not(offer_keyword: [nil, '']) }
  scope :for_product, -> { where.not(product_keyword: [nil, '']) }

  def self.record_offer_search!(attributes = {})
    record!(:offer_keyword, attributes)
  end

  def self.record_product_search!(attributes = {})
    record!(:product_keyword, attributes)
  end

  def self.record!(keyword_column, attributes = {})
    AffiliateSearchLogs::RecordSearchJob.perform_later(keyword_column, attributes)
  end

  def self.agg_offer_popularity
    agg_popularity(:offer)
  end

  def self.agg_product_popularity
    agg_popularity(:product)
  end

  def self.agg_popularity(keyword_type)
    keyword_column = "#{keyword_type}_keyword"
    keyword_count_column = "#{keyword_type}_keyword_count"

    logs = send("for_#{keyword_type}")
    total_count = logs.sum(keyword_count_column)

    logs
      .select(
        <<-SQL.squish
          #{keyword_column} AS keyword,
          SUM(#{keyword_count_column}) AS count,
          ROUND((SUM(#{keyword_count_column}) / (#{total_count})) * 100, 2) AS popularity
        SQL
      )
      .group(keyword_column)
      .order(popularity: :desc)
  end

  def offer_keyword_count
    super.to_i
  end

  def offer_keyword_count=(value)
    super(value.to_i)
  end

  def product_keyword_count
    super.to_i
  end

  def product_keyword_count=(value)
    super(value.to_i)
  end
end
