class AffiliateLogAgentSerializer < ApplicationSerializer
  attributes :id, :full_name, :avatar_cdn_url, :is_sender?

  def full_name
    object.try(:full_name)
  end

  def is_sender?
    current_user == object
  end
end
