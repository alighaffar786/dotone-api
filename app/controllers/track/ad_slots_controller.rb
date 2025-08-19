class Track::AdSlotsController < Track::BaseController
  skip_after_action :verify_same_origin_request

  def index
    ad_slot = AdSlot.cached_find(params[:id])
    ad_slot ||= AdSlot.new(affiliate_id: DotOne::Setup.missing_credit_affiliate_id, offer_ids: [DotOne::Setup.catch_all_offer_id])
    ads = []

    ads = fetch_cached_on_controller(params[:id], ad_slot.updated_at, expires_in: 3.hours) do
      inventory_agent = DotOne::AdSlots::InventoryAgent.new(ad_slot)
      inventory_agent.generate_inventories.presence
    end

    response = {
      ads: ads.to_a,
      global: {
        discount_price_text: t('.discount_price'),
        original_price_text: t('.original_price'),
        use_coupon_text: t('.use_coupon'),
      },
    }

    render json: response, callback: params[:callback]
  end
end
