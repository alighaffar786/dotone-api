module BlogContentHelpers::EsSearch
  extend ActiveSupport::Concern
  include EsSearchable

  included do
    settings index: { number_of_shards: 1 } do
      mapping dynamic: 'false' do
        indexes :id, type: 'long'
        indexes :title
        indexes :html
        indexes :short_description
      end
    end

    set_search_query_fields [
      'title^5',
      'short_description^3',
      'html',
    ]
  end

  def as_indexed_json(options = {})
    as_json(
      only: [
        :id,
        :title,
        :short_description,
        :html,
      ],
    )
  end
end
