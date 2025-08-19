module EsSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: [:create] do
      reindex('index')
    end

    after_update do
      if !respond_to?(:update_reindex?) || (respond_to?(:update_reindex?) && update_reindex?)
        reindex('update')
      end
    end

    after_commit on: [:destroy] do
      reindex('delete')
    end

    cattr_accessor :search_query_fields, :search_query_fields_for_email, :search_id_field
  end

  module ClassMethods
    def set_search_id_field(field)
      self.search_id_field = field
    end

    def set_search_query_fields(fields)
      self.search_query_fields = fields
    end

    def set_search_query_fields_for_email(fields)
      self.search_query_fields_for_email = fields
    end

    def sanitize_query(str)
      escaped_characters = Regexp.escape('\\/+-&|!(){}[]^~*?:')
      str.gsub(/([#{escaped_characters}])/, '\\\\\1')
    end

    def es_search(term, options = {})
      raw = options[:raw] == true

      return all if term.blank? && !raw

      term = '' if raw && term.blank?

      term = term.to_s

      # Set size to 100 (max: 10000)
      search_setup = {
        query: {
          multi_match: {
            query: sanitize_query(term),
            type: 'most_fields',
            fields: search_query_fields,
            lenient: true,
          },
        },
        size: (options[:size] || 100),
      }

      search_setup.merge!(size: options[:size]) if options[:size].present?

      if ValidateEmail.valid?(term) && search_query_fields_for_email.present?
        terms = []

        search_query_fields_for_email.each do |field|
          term_item = {}
          term_item[field] = { value: term.downcase }

          terms << { term: term_item }
        end

        search_setup = {
          query: {
            bool: {
              should: terms,
            },
          },
        }
      end

      result = __elasticsearch__.search(search_setup)

      if raw
        result
      else
        ids = result.map(&:id)
        id_field = search_id_field || :id

        result
          .records
          .merge(all)
          .where(id_field => ids)
          .reorder(Arel.sql("FIELD(#{table_name}.#{id_field}, '#{ids.join('\',\'')}')"))
      end
    end

    def es_bulk(body: nil)
      __elasticsearch__.client.bulk body: body
    end

    def es_bulk_update
      result = []

      all.in_batches do |records|
        documents = records.map do |record|
          {
            update: {
              _index: index_name,
              _type: document_type,
              _id: record.id,
              data: {
                doc: record.as_indexed_json,
                upsert: record.as_indexed_json,
              },
            },
          }
        end

        next unless documents.present?

        ExceptionHelper.catch_exception do
          result << es_bulk(body: documents)
        end
      end

      result
    end

    def es_bulk_delete
      result = []

      all.in_batches do |records|
        documents = records.map do |record|
          {
            delete: {
              _index: index_name,
              _type: document_type,
              _id: record.id,
            },
          }
        end

        next unless documents.present?

        ExceptionHelper.catch_exception do
          result << es_bulk(body: documents)
        end
      end

      result
    end
  end

  def reindex(operation = 'index')
    case operation.to_s
    when 'index'
      __elasticsearch__.index_document
    when 'update'
      __elasticsearch__.update_document
    when 'delete'
      __elasticsearch__.delete_document
    end
  rescue
    ElasticsearchIndexerJob.perform_later(operation, self.class.name, id)
  end
end
