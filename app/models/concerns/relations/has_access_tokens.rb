##
# Collection of helpers for AccessToken
module Relations::HasAccessTokens
  extend ActiveSupport::Concern

  included do
    has_many :access_tokens, as: :owner, inverse_of: :owner, class_name: 'AccessToken', dependent: :destroy
  end

  module ClassMethods
    def find_by_access_token(value)
      access_token = AccessToken.active.find_by_value(value)
      return unless access_token && access_token.owner.is_a?(self)

      access_token.refresh_last_used_at!
      access_token.owner
    end
  end

  def access_token
    @access_token ||=
      if respond_to?(:active_access_tokens)
        active_access_tokens.first.try(:value)
      else
        access_tokens.active.first.try(:value)
      end
  end
end
