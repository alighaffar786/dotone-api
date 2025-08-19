class ClientApi < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include Owned

  API_TYPES = ['Order Api', 'Product Api', 'Captured Conversion Api', 'Confirmed Conversion Api', 'Offer Api'].freeze
  STATUSES = ['Active', 'In Progress', 'Incomplete', 'Paused', 'Pending'].freeze
  OWNER_TYPES = ['Offer', 'Network', 'Affiliate'].freeze

  has_many :products, inverse_of: :client_api

  validates :host, uniqueness: { scope: [:owner_id, :owner_type, :api_type], allow_blank: true }
  validates :owner_type, inclusion: { in: ['Offer'] }, if: :product_api?
  validates :owner_id, uniqueness: { scope: [:api_type, :owner_type] }
  validates :name, inclusion: { in: -> (client_api) { ClientApi.module_types(client_api.api_type) } }, if: :api_type?

  serialize :column_settings

  define_constant_methods API_TYPES, :api_type
  define_constant_methods STATUSES, :status
  define_constant_methods OWNER_TYPES, :owner_type

  scope :considered_active, -> { where(status: [status_active, status_in_progress]) }

  def self.module_types(api_type)
    case api_type
    when api_type_offer_api
      ['OfferApi::Converly']
    when api_type_order_api
      [
        'OrderApi::Agoda',
        'OrderApi::Awin',
        'OrderApi::Cj',
        'OrderApi::Clickwise',
        'OrderApi::I3fresh',
        'OrderApi::Impact',
        'OrderApi::Linkshare',
        'OrderApi::Partnerize',
        'OrderApi::PepperJam',
        'OrderApi::Udn',
      ]
    when api_type_product_api
      [
        'ProductApi::Check2check',
        'ProductApi::Csv',
        'ProductApi::Dokodemo',
        'ProductApi::GoogleProduct',
        'ProductApi::I3fresh',
        'ProductApi::Kkday',
        'ProductApi::MatrixEC',
        'ProductApi::NineOneApp',
        'ProductApi::RakutenGlobal',
        'ProductApi::RakutenJp',
        'ProductApi::RakutenTw',
        'ProductApi::ShopeeTw',
        'ProductApi::YahooBuy',
        'ProductApi::Csv',
      ]
    when api_type_captured_conversion_api
      [
        'CapturedConversionApi::Portaly',
        'CapturedConversionApi::Post',
        'CapturedConversionApi::Line',
      ]
    when api_type_confirmed_conversion_api
      [
        'ConfirmedConversionApi::Line',
        'CapturedConversionApi::Portaly',
      ]
    end
  end

  ##
  # Returns api client for this client api
  def client(options = {})
    api_klass = "DotOne::ApiClient::#{name}::Client".constantize

    options = options.merge(
      id: id,
      key: key,
      host: host,
      api_affiliate_id: api_affiliate_id,
      auth_token: auth_token,
      username: username,
      password: password,
      request_body_content: request_body_content,
      path: path,
    )

    options[:related_offer] = owner if product_api?

    api_klass.new(options)
  end

  ##
  # Used by Captured Conversion API
  # to post any conversion
  def post_conversion(conversion_stat, options = {})
    return false if conversion_stat.blank?

    result = nil
    client = self.client(options)
    client.conversion_stat = conversion_stat
    client.send!
  end

  ##
  # Used by Order API to import order data
  # from Advertiser's API
  def import_orders(options = {})
    with_import do
      mark_as_import_in_progress
      current_client = client(options)

      current_client.each_item do |item|
        item.to_stat
      rescue Exception => e
        # Avoid obvious error from polutting the logs
        unless e.message == 'Order is in final state'
          ORDER_API_PULL_LOGGER.error "[#{Time.now}] Error #{id}: #{e.message}"
          ORDER_API_PULL_LOGGER.error "[#{Time.now}] #{e.backtrace.join("\r\n")}"
        end
        next
      end
    end
  end

  ##
  # Used by Product API to import product data
  # from Advertiser's API
  def import_products(options = {})
    with_import do
      return unless offer? && owner.active?
      mark_as_import_in_progress

      puts "Importing Product for #{name}..." if options[:console] == true
      current_client = client(options)
      current_client.download unless options[:download] == false
      options.merge!(client_api: self)
      current_client.to_items(options)
    end
  end

  def import(options = {})
    case api_type
    when ClientApi.api_type_order_api
      import_orders(options)
    when ClientApi.api_type_product_api
      import_products(options)
    end
  end

  def queue_import
    return unless active?

    case api_type
    when ClientApi.api_type_order_api
      ClientApis::OrderApi::PullJob.perform_later(id)
    when ClientApi.api_type_product_api
      ClientApis::ProductApi::PullJob.perform_later(id)
    end
  end

  def mark_as_import_in_progress
    update_column(:status, ClientApi.status_in_progress)
  end

  def mark_as_import_finished
    update_columns(status: ClientApi.status_active, imported_at: Time.now)
  end

  private

  def with_import
    return unless active?
    yield
    mark_as_import_finished
  end
end
