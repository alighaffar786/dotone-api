module DotOne::ApiClient::ProductApi
  class ItemCollection
    attr_accessor :collection, :map, :offer, :listed_product_ids, :client_api_id

    UNIQ_KEY_INDEX = 17
    REQUIRED_FIELDS = [
      :title,
      :product_url,
      :images,
      :prices,
    ]

    def initialize
      reset!

      @listed_product_ids = []
    end

    def reset!
      @collection = []
      @map = {}
    end

    def push(item, options = {})
      return if item.blank? || product_invalid?(item.product_data)

      PRODUCT_IMPORT_LOGGER.warn("Push #{item.client_api.owner_type} #{item.client_api.owner.id_with_name} item for bucket #{options[:bucket_index] || '1'}: #{item.product_data[:uniq_key]}")

      @collection << item
    end

    def process(index, options = {})
      proccessed = false
      collection_batch_size = options[:collection_batch_size] || 1000
      is_flushed = options[:flush] == true

      if item = @collection.first
        @client_api_id = item.product_data[:client_api_id]
        raise 'Client API ID missing' if @client_api_id.blank?
      end

      # Reset collection for next batch
      if is_flushed || (index % collection_batch_size == 0)
        PRODUCT_IMPORT_LOGGER.warn("Process #{@collection.length} items for bucket #{options[:bucket_index] || '1'}...")

        product_ids = @collection.map { |x| x.product_data[:uniq_key] }
        @listed_product_ids.concat(product_ids)

        products_before_save = {}

        Product
          .preload_es_relations
          .where(uniq_key: product_ids)
          .find_each do |product|
            products_before_save[product.uniq_key] = product.as_indexed_json
          end

        DotOne::Utils::Rescuer.no_deadlock do
          # Add new or update product to database
          Product.bulk_insert(update_duplicates: true) do |worker|
            @collection.each do |item|
              worker.add(item.product_data)
            end

            # Index product records to elastic search
            worker.after_save do |records|
              product_ids = records.map { |x| x[UNIQ_KEY_INDEX] }

              bulk_reindex(product_ids, products_before_save)
            end
          end
        end

        DotOne::Utils::Rescuer.no_deadlock do
          # Add product categories
          if @offer.present?
            ProductCategory.bulk_insert(update_duplicates: true) do |worker|
              @collection.each do |item|
                item.product_category_hash(@offer).each do |hash|
                  worker.add(hash)
                end
              end
            end
          end
        end

        puts 'DONE' if options[:console] == true
        proccessed = true
        reset!
      end

      delete_unlisted_products if is_flushed

      proccessed
    end

    def bulk_reindex(product_ids, products_before_save)
      uniq_keys = []

      Product
        .preload_es_relations
        .where(uniq_key: product_ids)
        .in_batches do |products|
          uniq_keys += products
            .reject { |product| products_before_save[product.uniq_key] == product.as_indexed_json }
            .map(&:uniq_key)
        end

      return if uniq_keys.blank?

      Product
        .preload_es_relations
        .where(uniq_key: uniq_keys)
        .es_bulk_update
    end

    def delete_unlisted_products
      return unless client_api_id

      unlisted = Product.where.not(uniq_key: listed_product_ids).where(client_api_id: client_api_id)
      unlisted_size = unlisted.count

      return if unlisted_size == 0

      PRODUCT_IMPORT_LOGGER.warn('Delete unlisted products...')

      unlisted.es_bulk_delete
      unlisted.delete_all

      Product.order(updated_at: :desc).first&.touch

      PRODUCT_IMPORT_LOGGER.warn("#{unlisted_size} of unlisted products are deleted")
    end

    def product_invalid?(product_data)
      return true if product_data[:inventory_status] != 'In Stock'

      REQUIRED_FIELDS.any? do |field|
        if field == :prices
          price = product_data.dig(field, :retail, 'TWD')
          price.blank? || price <= 0
        else
          product_data[field].blank?
        end
      end
    end
  end
end
