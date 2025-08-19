module NetworkHelpers::EsSearch
  extend ActiveSupport::Concern
  include EsSearchable

  included do
    settings(
      index: {
        number_of_shards: 4,
        number_of_replicas: 1
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
            type: 'ngram', min_gram: 2, max_gram: 5
          },
        },
      },
    ) do
      mapping dynamic: 'false' do
        indexes :id, type: 'long'
        indexes :name, analyzer: 'partial_analyzer'
        indexes :contact_name, analyzer: 'partial_analyzer'
        indexes :brands, analyzer: 'partial_analyzer'
        indexes :company_url, analyzer: 'partial_analyzer'
        indexes :contact_email, { type: 'keyword' }
        indexes :contact_lists do
          indexes :first_name, analyzer: 'partial_analyzer'
          indexes :last_name, analyzer: 'partial_analyzer'
          indexes :email, { type: 'keyword' }
        end
        indexes :keyword_set do
          indexes :keywords
          indexes :internal_keywords
        end
      end
    end

    set_search_query_fields [
      'id^200',
      'name^10',
      'contact_name',
      'brands^50',
      'contact_email',
      'contact_phone',
      'company_url^10',
      'contact_lists.first_name',
      'contact_lists.last_name',
      'contact_lists.email',
      'keyword_set.keywords^2',
      'keyword_set.internal_keywords^2',
    ]

    set_search_query_fields_for_email [
      'contact_email',
      'contact_lists.email',
    ]
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :id,
        :name,
        :contact_name,
        :brands,
        :contact_email,
        :contact_phone,
        :company_url,
      ],
      include: {
        contact_lists: {
          only: [
            :email,
            :first_name,
            :last_name,
          ],
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
end
