require 'csv'

class DotOne::Products::Exporter < DotOne::Exporters::Base
  attr_reader :affiliate_id, :include_all

  def initialize(affiliate_id, **options)
    @affiliate_id = affiliate_id
    @include_all = options[:include_all]
  end

  def should_export?
    query_products.any?
  end

  def download
    return false unless should_export?

    output = export_csv

    download = Download.create(
      owner: Affiliate.find(affiliate_id),
      name: "Product Download (#{Date.today})",
      file: File.open(output),
      status: Download.status_ready,
    )

    File.delete(output) rescue nil

    download.cdn_url
  end

  def header
    [
      :client_id_value,
      :universal_id_value,
      :description_1,
      :description_2,
      :brand,
      :category_1,
      :category_2,
      :category_3,
      :product_url,
      :is_new,
      :is_promotion,
      :promo_start_at,
      :promo_end_at,
      :inventory_status,
      :locale,
      :currency,
      :uniq_key,
      :offer_id,
      :prices,
      :images,
      :additional_attributes,
      :tracking_url,
    ].map(&:to_s)
  end

  def body
    return @body if @body.present?

    @body = []

    columns = header.reject { |x| x == 'tracking_url' }
    query_products.find_each do |product|
      affiliate_offer = affiliate_offers[product.offer_id]
      @body << [
        *product.attributes.slice(*columns).values,
        affiliate_offer&.to_tracking_url(t: product.product_url, t_encrypted: true)
      ]
    end

    @body
  end

  def affiliate_offers
    @affiliate_offers ||= AffiliateOffer
      .active
      .joins(offer: :default_offer_variant)
      .where(affiliate_id: affiliate_id)
      .where(offers: { type: 'NetworkOffer' })
      .where(offer_variants: { status: OfferVariant.status_considered_positive })
      .index_by(&:offer_id)
  end

  def query_products
    Product
      .where(inventory_status: 'In Stock')
      .where(offer_id: (include_all ? NetworkOffer.active_public : affiliate_offers.keys))
  end
end
