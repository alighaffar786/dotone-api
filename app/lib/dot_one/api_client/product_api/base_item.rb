require 'digest/sha1'

##
# Module that is being shared by class implementing Product Item
# on ProductApi.
module DotOne::ApiClient::ProductApi
  class BaseItem
    attr_accessor :product_data, :price_data, :image_data, :additional_attributes, :locale, :currency, :client_api

    def initialize_price_data
      {
        retail: {},
        sale: {},
        discount: {},
      }
    end

    def to_uniq_key(*args)
      uniq_key_elements = []

      uniq_key_elements << @client_api.id if @client_api.present?

      uniq_key_elements += [
        @product_data[:client_id_value],
        @product_data[:offer_id],
        @locale,
        @currency,
        *args,
      ]

      Digest::SHA1.hexdigest(uniq_key_elements.compact.join(' - '))
    end

    def product_category_hash(related_offer)
      values = []
      if related_offer.present? && @product_data && @product_data[:category_1].present?
        values << {
          offer_id: related_offer.id,
          locale: @locale,
          name: @product_data[:category_1],
        }
      end
      values
    end
  end
end
