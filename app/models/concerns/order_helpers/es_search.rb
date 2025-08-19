module OrderHelpers::EsSearch
  extend ActiveSupport::Concern
  include EsSearchable

  included do
    settings(
      index: {
        number_of_shards: 3,
        number_of_replicas: 1,
      }
    ) do
      mapping dynamic: 'false' do
        indexes :id, type: 'integer'
        indexes :affiliate_stat_id, type: 'keyword'
        indexes :order_number, type: 'keyword'
        indexes :order_number_lowercase, type: 'keyword'
        indexes :copy_stat do
          indexes :id, type: 'keyword'
        end
      end
    end

    set_search_query_fields [
      'id',
      'order_number^2',
      'order_number_lowercase^2',
      'affiliate_stat_id',
      'copy_stat.id'
    ]
  end

  module ClassMethods
    def es_search_by(terms, options = {})
      column = options[:column]&.to_sym || :order_number
      partial = options[:partial] == true
      partial_by = (options[:partial_by].presence || :start_with).to_sym
      raw = options[:raw] == true
      size = options[:size] || 1000
      from = options[:from] || 0

      search_setup = { query: { }, size: size, from: from }

      search_setup[:query] = if terms.present?
        terms = [terms].flatten.map(&:downcase).uniq
        column = column == :order_number ? :order_number_lowercase : column

        if partial
          {
            bool: {
              should: terms.map do |term|
                term = case partial_by
                when :end_with
                  term = "*#{term}"
                when :contain
                  term = "*#{term}*"
                else
                  term = "#{term}*"
                end

                { wildcard: { "#{column}.keyword": term } }
              end
            }
          }
        else
          { terms: { "#{column}.keyword": terms } }
        end
      else
        { match_none: {} }
      end

      result = __elasticsearch__.search(search_setup)
      result = result.records if !raw
      result
    end
  end

  def update_reindex?
    previous_changes.include?(:order_number)
  end

  def order_number_lowercase
    order_number.downcase
  end

  def as_indexed_json(options = {})
    as_json(
      only: [:id, :affiliate_stat_id, :order_number],
      include: {
        copy_stat: {
          only: [:id]
        }
      },
      methods: [:order_number_lowercase]
    )
  end

  def reindex(operation = 'index')
    if operation.to_s == 'update'
      __elasticsearch__.index_document
    else
      super(operation)
    end
  end
end
