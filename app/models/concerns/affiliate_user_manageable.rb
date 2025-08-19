module AffiliateUserManageable
  extend ActiveSupport::Concern

  included do
    scope :with_affiliate_users, -> (*affiliate_users) {
      result = nil

      affiliate_users.flatten.each do |affiliate_user|
        ability = Ability.new(affiliate_user)

        result = if result
          result.or(accessible_by(ability))
        else
          accessible_by(ability)
        end
      end

      result
    }

    scope :with_affiliate_user, -> (*affiliate_users) {
      with_affiliate_users(affiliate_users.first)
    }
  end
end
