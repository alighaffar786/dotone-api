class Advertisers::AffiliateSerializer < Base::AffiliateSerializer
  attributes :id, :avatar_cdn_url, :status, :source, :label, :direct?, :last_joined_at

  conditional_attributes :email, :name, :nickname, :last_name, :messenger_service, :messenger_service_2,
    :messenger_id, :messenger_id_2, if: :can_read_affiliate?

  conditional_attributes :first_name, if: -> { can_read_affiliate? || partial_pro_network? }

  conditional_attributes :captured, :clicks, if: :conversion_exist?

  has_many :network_logs, key: :logs, if: :full_scope?
  has_many :site_infos, if: :full_scope?

  def name
    object.full_name
  end

  def last_joined_at
    object.try(:last_joined_at)
  end

  def clicks
    instance_options.dig(:affiliate_conversion_count, object.id, :clicks).to_i
  end

  def captured
    instance_options.dig(:affiliate_conversion_count, object.id, :captured).to_i
  end

  def conversion_exist?
    instance_options.keys.include?(:affiliate_conversion_count)
  end

  def network_logs
    object.network_logs.select { |log| [nil, current_user.id].include?(log.agent_id) }
  end
end
