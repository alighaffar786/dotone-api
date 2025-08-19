module Relations::HasApiKeys
  extend ActiveSupport::Concern

  included do
    has_many :api_keys, -> { where(type: nil) }, as: :owner, inverse_of: :owner, dependent: :destroy
  end

  module ClassMethods
    def find_by_api_key(value)
      api_key = ApiKey.api_keys.active.find_by_value(value)
      return unless api_key && api_key.owner.is_a?(self)

      api_key.refresh_last_used_at!
      api_key.owner
    end
  end

  def api_key
    @api_key ||=
      if respond_to?(:active_api_keys)
        active_api_keys.first.try(:value)
      else
        api_keys.active.first.try(:value)
      end
  end
end
