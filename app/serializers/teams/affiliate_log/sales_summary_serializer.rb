class Teams::AffiliateLog::SalesSummarySerializer < ApplicationSerializer
  attributes :id, :full_name, :roles, :kpi

  AffiliateLog.sales_metrics.each { |metric| attribute metric }
end
