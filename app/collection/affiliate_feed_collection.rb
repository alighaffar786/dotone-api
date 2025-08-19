class AffiliateFeedCollection < BaseCollection
  private

  def ensure_filters
    super
    filter_by_feed_types if params[:feed_types].present?
    filter_by_role if params[:role].present?
    filter_by_statuses if params[:statuses].present?
    filter_by_country_ids if params[:country_ids].present?
  end

  def filter_by_feed_types
    filter { @relation.with_feed_types(params[:feed_types]) }
  end

  def filter_by_role
    filter { @relation.with_roles(params[:role]) }
  end

  def default_sorted
    sort do
      @relation.order(sticky: :desc).recent
    end
  end

  def filter_by_statuses
    filter { @relation.where(status: params[:statuses]) }
  end

  def filter_by_country_ids
    filter { @relation.with_countries(params[:country_ids]) }
  end

  def sort_by_published_at
    sort do
      @relation.order(
        Arel.sql(
          <<~SQL.squish
            CASE
              WHEN sticky = 1 AND sticky_until > NOW() THEN 2
              ELSE 1
            END #{sort_order},
            published_at #{sort_order}
          SQL
        )
      )
    end
  end
end
