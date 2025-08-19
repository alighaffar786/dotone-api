class Advertisers::StatSummarySerializer < Base::StatSummarySerializer
  generate DotOne::Reports::Networks::StatSummary
end
