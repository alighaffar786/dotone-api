class AttachmentSerializer < ApplicationSerializer
  local_time_attributes(*Attachment.local_time_attributes)

  attributes :id, :name, :link, :link_url, :created_at, :owner_type, :owner_id

  has_one :uploader

  def self.serializer_for(model, options)
    case model.class.name
    when 'Affiliate'
      Teams::Affiliate::MiniSerializer
    when 'AffiliateUser'
      Teams::AffiliateUser::MiniSerializer
    when 'Network'
      Teams::Network::MiniSerializer
    else
      super
    end
  end

  # TODO: fix polymorphic
  def uploader
    object.uploader_type.classify.constantize.find(object.uploader_id)
  rescue
  end
end
