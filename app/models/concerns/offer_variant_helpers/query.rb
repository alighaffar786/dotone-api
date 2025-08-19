module OfferVariantHelpers::Query
  extend ActiveSupport::Concern

  module ClassMethods
    def status_priority_sql
      case_sqls = statuses_sorted.each_with_index.map do |status, index|
        <<-SQL.squish
          WHEN '#{status}' THEN #{index}
        SQL
      end

      <<-SQL.squish
        CASE offer_variants.status
          #{case_sqls.join(' ')}
          ELSE #{statuses_sorted.length}
        END as status_priority
      SQL
    end
  end
end
