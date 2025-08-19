# frozen_string_literal: true

class AffiliateOffers::BulkUpdateJob < EntityManagementJob
  def perform(user:, ids:, params: {})
    ability = Ability.new(user)
    affiliate_offers = AffiliateOffer.accessible_by(ability, :update)

    ids.each_slice(50) do |current_ids|
      affiliate_offers.where(id: current_ids).each do |record|
        catch_exception { record.update!(params) }
      end
    end
  end
end
