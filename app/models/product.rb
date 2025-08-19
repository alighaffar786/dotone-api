class Product < DatabaseRecords::PrimaryRecord
  include BulkInsertable
  include DateRangeable
  include LocalTimeZone
  include ProductHelpers::EsSearch

  self.table_name = 'offer_products'
  self.primary_key = :uniq_key

  attr_accessor :max_commission

  belongs_to :client_api, inverse_of: :products
  belongs_to :offer, -> { where(type: 'NetworkOffer') }, inverse_of: :products

  after_commit on: [:destroy] do
    Product.order(updated_at: :desc).first&.touch
  end

  validates :client_api_id, :offer_id, :title, :product_url, :images, :prices, presence: true

  set_local_time_attributes :created_at, :updated_at

  scope :with_promotion, -> (*args) {
    where(is_promotion: args.map { |arg| BooleanHelper.truthy?(arg) }) if args.present?
  }

  scope :with_locales, -> (*args) { where(locale: args) if args.present? }

  def self.initialize_safely(params)
    attrs = params.to_h.slice(*Product.column_names)
    new(attrs)
  end

  def self.preload_es_relations
    preload(offer: [:name_translations, :keyword_set])
  end

  def self.unindexed_ids
    Product.find_in_batches(batch_size: 1000) do |products|
      batch_unindexed = []
      response = Product.__elasticsearch__.client.mget(
        index: Product.index_name,
        type: Product.document_type,
        body: { ids: products.pluck(:uniq_key) }
      )
      response['docs'].each do |document|
        next if document['found']

        batch_unindexed.push(document['_id'])
      end

      yield batch_unindexed if block_given?
    end
  end

  def descriptions
    [description_1, description_2].uniq.reject(&:blank?)
  end

  def retail_prices
    prices ? prices['retail'] : {}
  end

  def sale_prices
    prices ? prices['sale'] : {}
  end

  def price
    @price ||= if is_promotion?
      sale_prices[Currency.default_code]
    else
      retail_prices[Currency.default_code]
    end
  end

  def forex_price(currency_code)
    if is_promotion?
      forex_sale_price(currency_code)
    else
      forex_retail_price(currency_code)
    end
  end

  def forex_retail_price(currency_code)
    rate = Currency.rate_from_default(currency_code)
    retail_prices[currency_code] || (retail_prices[Currency.default_code].to_f * rate)
  end

  def forex_sale_price(currency_code)
    return 0 unless is_promotion?

    rate = Currency.rate_from_default(currency_code)
    sale_prices[currency_code] || (sale_prices[Currency.default_code].to_f * rate)
  end
end
