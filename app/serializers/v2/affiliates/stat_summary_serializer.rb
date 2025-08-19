class V2::Affiliates::StatSummarySerializer < Base::StatSummarySerializer
  generate DotOne::Reports::Affiliates::StatSummary

  def include_id?
    false
  end
end
