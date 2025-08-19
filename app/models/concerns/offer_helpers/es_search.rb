module OfferHelpers::EsSearch
  extend ActiveSupport::Concern
  include EsSearchable

  included do
    settings(
      index: {
        number_of_shards: 96,
        number_of_replicas: 4,
      },
      analysis: {
        analyzer: {
          partial_analyzer: {
            tokenizer: 'partial_tokenizer',
            filter: ['lowercase'],
          },
        },
        tokenizer: {
          partial_tokenizer: {
            type: 'ngram',
            min_gram: 2,
            max_gram: 5,
          },
        },
      },
    ) do
      mapping dynamic: 'false' do
        indexes :id, type: 'long'
        indexes :name, analyzer: 'partial_analyzer'
        indexes :client_offer_name, analyzer: 'partial_analyzer'
        indexes :whitelisted_destination_urls, analyzer: 'partial_analyzer'
        indexes :keyword_set do
          indexes :keywords, analyzer: 'partial_analyzer'
          indexes :internal_keywords, analyzer: 'partial_analyzer'
        end
      end
    end

    set_search_query_fields [
      'id^200',
      'name^2',
      'client_offer_name',
      'keyword_set.keywords^2',
      'keyword_set.internal_keywords^2',
      'name_translations.content^2',
      'whitelisted_destination_urls',
    ]

    after_save :reindex_products, if: :need_reindex?
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :id,
        :name,
        :client_offer_name,
        :whitelisted_destination_urls,
      ],
      include: {
        name_translations: {
          only: [:content],
        },
        keyword_set: {
          only: [
            :keywords,
            :internal_keywords,
          ],
        },
      },
    )
  end

  def need_reindex?
    name_previously_changed? ||
      translations.any? { |t| t.field == 'name' && t.content_previously_changed? } ||
      keyword_set&.keywords_previously_changed? ||
      keyword_set&.internal_keywords_previously_changed?
  end

  def reindex_products
    NetworkOffers::ReindexProductsJob.perform_later(id)
  end
end
