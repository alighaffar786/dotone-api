class Teams::OwnerHasTagSerializer < ApplicationSerializer
  attributes :id, :access_type, :owner_type, :owner_id, :display_order, :affiliate_tag_id

  has_one :affiliate_tag
  has_one :owner, if: :include_owner?

  def self.serializer_for(model, options)
    case model.class.name
    when 'NetworkOffer'
      Teams::NetworkOffer::FeaturedSerializer
    else
      super
    end
  end

  def include_owner?
    instance_options[:owner]
  end

  def owner
    if instance_options[:owners].present?
      instance_options[:owners][object.id]
    else
      object.owner
    end
  end
end
