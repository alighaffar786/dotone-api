class Base::StatSummarySerializer < ApplicationSerializer
  class TextCreativeSerializer < Base::TextCreativeSerializer
    attributes :id, :creative_name
  end

  class ImageCreativeSerializer < Base::ImageCreativeSerializer
    attributes :id, :size
  end

  class OfferVariantSerializer < Base::OfferVariantSerializer
    attributes :id, :full_name
  end

  class NetworkOfferSerializer < Base::NetworkOfferSerializer
    attributes :id, :name
  end

  class NetworkSerializer < Base::NetworkSerializer
    attributes :id

    [:name, :contact_email, :status, :billing_email, :payment_term, :payment_term_days, :universal_number].each do |attr|
      attribute attr, if: :can_read_network?
    end

    has_one :country, if: -> { column_requested?(:network_country) }
    has_many :contact_lists, if: -> { column_requested?(:contact_lists) }
  end

  class MediaCategorySerializer < Base::AffiliateTagSerializer
    attributes :id, :name
  end

  class AffiliateSerializer < Base::AffiliateSerializer
    attributes :id
    attribute :name, if: :can_read_affiliate?

    has_many :media_categories, serializer: MediaCategorySerializer, if: -> { column_requested?(:media_categories) }
  end

  attribute :id, if: :include_id?

  has_one :offer, serializer: NetworkOfferSerializer, if: -> { column_requested?(:offer_id) }
  has_one :offer_variant, serializer: OfferVariantSerializer, if: -> { column_requested?(:offer_variant_id) }
  has_one :image_creative, serializer: ImageCreativeSerializer, if: -> { column_requested?(:image_creative_id) }
  has_one :text_creative, serializer: TextCreativeSerializer, if: -> { column_requested?(:text_creative_id) }
  has_one :network, serializer: NetworkSerializer, if: -> { column_requested?(:network_id) }
  has_one :affiliate, serializer: AffiliateSerializer, if: -> { column_requested?(:affiliate_id) }

  def self.generate(report_klass)
    report_klass.columns.each do |column|
      attribute column, if: -> { column_requested?(column) }
    end

    report_klass.dimensions.each do |column|
      next unless relation_name = report_klass.to_relation_name(column)

      collection_name = relation_name.to_s.pluralize.to_sym

      define_method relation_name do
        collection = instance_options[collection_name] || {}
        return unless relation_id = object.send(column)

        collection[relation_id] || object.send(relation_name)
      end
    end

    report_klass.metrics.each do |column|
      define_method column do
        object.send(column) || 0
      end
    end

    define_method :id do
      [report_klass.dimensions, :date].flatten.map do |column|
        object.send(column) || 0 if object.respond_to?(column)
      end.join('-')
    end
  end

  def date
    object.date.to_date
  end

  def include_id?
    true
  end
end
