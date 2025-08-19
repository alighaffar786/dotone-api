module ProductHelpers::EsSearch
  extend ActiveSupport::Concern
  include EsSearchable

  included do
    index_name 'offer_products'
    document_type 'offer_products'

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
        indexes :title, analyzer: 'partial_analyzer'
        indexes :description_1, analyzer: 'partial_analyzer'
        indexes :description_2, analyzer: 'partial_analyzer'
        indexes :brand, analyzer: 'partial_analyzer'
        indexes :offer do
          indexes :keyword_set do
            indexes :keywords, analyzer: 'partial_analyzer'
            indexes :internal_keywords, analyzer: 'partial_analyzer'
          end
        end
      end
    end

    set_search_id_field :uniq_key

    set_search_query_fields [
      'title^10',
      'offer.name^10',
      'offer.name_translations.content^10',
      'description_1^5',
      'description_2^5',
      'brand',
      'offer.keyword_set.keywords^10',
      'offer.keyword_set.internal_keywords^10',
    ]
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :title,
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
        :locale,
        :currency,
        :uniq_key,
        :offer_id,
        :prices,
        :images,
      ],
      include: {
        offer: {
          only: [
            :name,
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
        },
      },
    )
  end
end
