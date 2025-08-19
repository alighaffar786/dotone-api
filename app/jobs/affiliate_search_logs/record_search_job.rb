class AffiliateSearchLogs::RecordSearchJob < EntityManagementJob
  retry_on ActiveRecord::Deadlocked

  def perform(keyword_column, attributes)
    keyword = attributes[keyword_column]&.strip

    return if keyword.blank?

    affiliate_search_logs = AffiliateSearchLog.where(
      affiliate_id: attributes[:affiliate_id],
      date: attributes[:date],
      keyword_column => [keyword, nil]
    )

    AffiliateSearchLog.transaction do
      object = affiliate_search_logs.lock.first_or_initialize

      object[keyword_column] = keyword
      object["#{keyword_column}_count"] += 1
      object.save!
    rescue ActiveRecord::RecordInvalid
      affiliate_search_logs
        .order(created_at: :desc)
        .offset(1)
        .destroy_all

      retry
    end
  end
end
