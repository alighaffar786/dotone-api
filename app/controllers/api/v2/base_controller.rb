class Api::V2::BaseController < Api::BaseController
  include Api::V2::ResponseHandler

  before_action do
    self.namespace_for_serializer = V2
  end

  def current_user
    return if both_key_blank?

    @current_user ||= begin
      if api_key
        api_key.refresh_last_used_at!
        api_key.cached_owner if api_key.cached_owner.active?
      elsif legacy_api_key
        Network.cached_find(legacy_api_key.network_id)
      end
    end
  end

  def api_key
    return if both_key_blank?

    @api_key ||= ApiKey.active.find_by(value: params[:api_key].presence || params[:api].presence)
  end

  def both_key_blank?
    params[:api].to_s.strip.blank? && params[:api_key].to_s.strip.blank?
  end

  def legacy_api_key
    return if params[:api].to_s.strip.blank?

    @legacy_api_key ||= DotOne::Utils::ApiKey.new(params[:api])
  end
end
