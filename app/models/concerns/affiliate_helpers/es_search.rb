module AffiliateHelpers::EsSearch
  extend ActiveSupport::Concern
  include EsSearchable

  included do
    settings(
      index: {
        number_of_shards: 4,
        number_of_replicas: 1,
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
        indexes :first_name, analyzer: 'partial_analyzer'
        indexes :last_name, analyzer: 'partial_analyzer'
        indexes :email, { type: 'keyword' }
        indexes :username, analyzer: 'partial_analyzer'
        indexes :nickname, analyzer: 'partial_analyzer'
        indexes :affiliate_application do
          indexes :company_name, analyzer: 'partial_analyzer'
          indexes :phone_number
          indexes :mobile_phone_number
          indexes :keyword_set do
            indexes :keywords
            indexes :internal_keywords
          end
        end

        indexes :site_infos do
          indexes :keyword_set do
            indexes :keywords
            indexes :internal_keywords
          end
        end

        indexes :keyword_set do
          indexes :keywords
          indexes :internal_keywords
        end
      end
    end

    set_search_query_fields [
      'id^200',
      'email^2',
      'first_name',
      'last_name',
      'username',
      'nickname',
      'affiliate_application.company_name',
      'affiliate_application.phone_number',
      'affiliate_application.mobile_phone_number',
      'affiliate_application.keyword_set.keywords^2',
      'affiliate_application.keyword_set.internal_keywords^2',
      'site_infos.keyword_set.keywords^2',
      'site_infos.keyword_set.internal_keywords^2',
      'keyword_set.keywords^2',
      'keyword_set.internal_keywords^2',
    ]

    set_search_query_fields_for_email [
      'email',
    ]
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :id,
        :first_name,
        :last_name,
        :email,
        :username,
        :nickname,
      ],
      include: {
        affiliate_application: {
          only: [
            :company_name,
            :phone_number,
            :mobile_phone_number,
          ],
          include: {
            keyword_set: {
              only: [
                :keywords,
                :internal_keywords,
              ],
            },
          },
        },
        site_infos: {
          include: {
            keyword_set: {
              only: [
                :keywords,
                :internal_keywords,
              ],
            },
          },
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
