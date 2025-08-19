module Roleable
  extend ActiveSupport::Concern

  def generic_role
    @role = self.class.name.underscore.to_sym
    @role = :owner if @role == :affiliate_user
    @role
  end

  def roles
    super
  rescue
    if instance_of?(::Network)
      'Advertiser'
    elsif instance_of?(::Affiliate)
      'Affiliate'
    end
  end

  def name_with_role(allow_blank: false)
    name = full_name if respond_to?(:full_name)
    name ||= 'none' unless allow_blank
    "#{name} (#{roles})"
  end

  # TODO:: deprecate
  def avatar_cdn_url
    url = super.presence
    url ||= avatar&.cdn_url if avatar.is_a?(Image)
    url ||= avatar.url if avatar.is_a?(CarrierWave::Uploader::Base)
    url == '/images/no-profile-300x300.jpg' ? nil : url
  end
end
