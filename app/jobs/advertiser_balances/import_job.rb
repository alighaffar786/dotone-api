# frozen_string_literal: true

class AdvertiserBalances::ImportJob < EntityManagementJob
  discard_on ActiveRecord::RecordNotFound

  def perform(upload_id)
    importer = DotOne::AdvertiserBalances::Importer.new(upload_id)
    importer.import
  end
end
