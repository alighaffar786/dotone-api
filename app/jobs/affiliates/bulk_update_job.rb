# frozen_string_literal: true

class Affiliates::BulkUpdateJob < EntityManagementJob
  def perform(user:, ids:, params: {})
    ability = Ability.new(user)
    affiliates = Affiliate.accessible_by(ability, :update).where(id: ids)

    update_params = params.compact_blank
    add_affiliate_user_ids = update_params.delete(:add_affiliate_user_ids).to_a
    remove_affiliate_user_ids = update_params.delete(:remove_affiliate_user_ids).to_a

    affiliates.find_each do |affiliate|
      catch_exception do
        affiliate_user_ids = [*affiliate.affiliate_user_ids, *add_affiliate_user_ids].uniq - remove_affiliate_user_ids
        affiliate.update!(update_params.merge(affiliate_user_ids: affiliate_user_ids))
      end
    end
  end
end
