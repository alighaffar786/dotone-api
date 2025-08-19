class Api::Client::Teams::Reports::TasksController < Api::Client::Teams::BaseController
  def index
    authorize! :read, AffiliateUser

    result = fetch_cached_on_controller(expires_in: 30.minutes) do
      {
        pending_offer_campaigns: count_pending_offer_campaigns,
        pending_event_campaigns: count_pending_event_campaigns,
        pending_payment_infos: count_pending_payment_infos,
        pending_conversions: count_pending_conversions,
        pending_image_creatives: count_pending_creatives(ImageCreative),
        pending_text_creatives: count_pending_creatives(TextCreative),
        negative_balance_networks: count_negative_balance_networks,
        pending_missing_orders: count_pending_missing_orders,
        confirming_missing_orders: count_confirming_missing_orders,
      }
    end

    respond_with result.compact
  end

  private

  def accessible_by(entity)
    entity.accessible_by(current_ability)
  end

  def count_pending_campaigns(type)
    accessible_by(AffiliateOffer).joins(:offer).where(offers: { type: type }).pending.count
  end

  def count_pending_offer_campaigns
    count_pending_campaigns('NetworkOffer') if can?(:read, NetworkOffer) && can?(:update, AffiliateOffer)
  end

  def count_pending_event_campaigns
    count_pending_campaigns('EventOffer') if can?(:read, EventOffer) && can?(:update, AffiliateOffer)
  end

  def count_pending_payment_infos
    accessible_by(AffiliatePaymentInfo).pending.count if can?(:update, AffiliatePaymentInfo)
  end

  def count_pending_conversions
    return unless can?(:update, AffiliateStatCapturedAt)

    date_range = current_time_zone.local_range(:last_90_days)
    accessible_by(AffiliateStatCapturedAt).between(*date_range, :captured_at, current_time_zone).pending.count
  end

  def count_pending_creatives(klass)
    accessible_by(klass).with_active_offers.pending.count if can?(:update, klass)
  end

  def count_pending_missing_orders
    accessible_by(MissingOrder).pending.count if can?(:update, MissingOrder)
  end

  def count_confirming_missing_orders
    accessible_by(MissingOrder).confirming.count if can?(:update, MissingOrder)
  end

  def count_negative_balance_networks
    return unless can?(:update, AdvertiserBalance)

    pending_payouts = Stat.network_pending_payouts
    published_payouts = Stat.network_published_payouts

    balances = accessible_by(AdvertiserBalance).agg_final_balance.preload(network: :billing_currency)
    balances.each do |balance|
      network = balance.network
      network.current_balance = balance.forex_final_balance
      network.pending_payout = pending_payouts[balance.network_id]&.pending_true_pay.to_f
      network.published_payout = published_payouts[balance.network_id]&.published_true_pay.to_f
    end

    balances.count { |balance| balance.network.remaining_balance < 0 }
  end
end
