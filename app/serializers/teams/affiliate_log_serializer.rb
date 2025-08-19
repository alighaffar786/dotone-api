class Teams::AffiliateLogSerializer < AffiliateLogSerializer
  attributes :contact_target, :contact_media, :contact_stage, :sales_pipeline
  attribute :crm_contact_medias, unless: :for_sales?

  has_one :crm_target, serializer: Teams::CrmTargetSerializer, unless: :for_sales?
  has_one :owner, serializer: Teams::Network::MiniSerializer, if: :for_sales?

  def for_sales?
    instance_options[:sales]
  end
end
