class AffiliatePayments::CreateProposalJob < EntityManagementJob
  def perform(options)
    exporter = DotOne::AffiliatePayments::Exporter.new(options)
    exporter.export
  end
end
