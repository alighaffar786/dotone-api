# frozen_string_literal: true

class AffiliatePayments::ImportJob < EntityManagementJob
  def perform(upload_id)
    importer = DotOne::AffiliatePayments::Importer.new(upload_id)
    importer.import
  end
end
