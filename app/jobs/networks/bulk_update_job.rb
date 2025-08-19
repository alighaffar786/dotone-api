# frozen_string_literal: true

class Networks::BulkUpdateJob < EntityManagementJob
  def perform(user:, ids:, params: {})
    ability = Ability.new(user)
    networks = Network.accessible_by(ability, :update).where(id: ids)

    update_params = params.compact_blank
    add_affiliate_user_ids = update_params.delete(:add_affiliate_user_ids).to_a
    remove_affiliate_user_ids = update_params.delete(:remove_affiliate_user_ids).to_a

    networks.find_each do |network|
      catch_exception do
        affiliate_user_ids = [*network.affiliate_user_ids, *add_affiliate_user_ids].uniq - remove_affiliate_user_ids
        network.update!(update_params.merge(affiliate_user_ids: affiliate_user_ids))
      end
    end
  end
end
