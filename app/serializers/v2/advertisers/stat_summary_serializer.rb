class V2::Advertisers::StatSummarySerializer < Base::StatSummarySerializer
  generate DotOne::Reports::Networks::StatSummary

  def include_id?
    false
  end
end
