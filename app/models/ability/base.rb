class Ability::Base
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user
    user ? user_rules : []
  end

  def user_rules
    raise NotImplementedError
  end

  protected

  def when_me
    { id: user.id }
  end

  def when_owned
    { owner_id: user.id, owner_type: user.class.name }
  end

  def when_agent
    { agent_id: user.id, agent_type: user.class.name }
  end

  def when_author
    { author_id: user.id, author_type: user.class.name }
  end

  def when_ad_slots_active
    { status: AdSlot.status_active }
  end

  def when_affiliate_feeds_published
    { status: AffiliateFeed.status_published }
  end

  def when_affiliate_feeds_active
    when_affiliate_feeds_published.merge(id: AffiliateFeed.active.select(:id))
  end

  def when_affiliate_offers_active
    { approval_status: AffiliateOffer.approval_status_active }
  end

  def when_affiliate_offers_cancelled
    { approval_status: AffiliateOffer.approval_status_cancelled }
  end

  def when_group_tag
    { tag_type: AffiliateTag.tag_type_group_tag }
  end

  def when_blog_tag
    { tag_type: AffiliateTag.tag_type_blog_tag }
  end

  def when_with_event_affiliate_offer_approvals
    { approval_status: AffiliateOffer.event_approval_statuses }
  end

  def when_affiliate_payment_redeemable
    {
      payment_info_status: AffiliatePaymentInfo.status_confirmed,
      status: AffiliatePayment.status_redeemable,
    }
  end

  def when_affiliate_payment_info_pending
    { status: AffiliatePaymentInfo.status_considered_pending }
  end

  def when_affiliate_payment_pending
    { status: AffiliatePayment.status_pending }
  end

  def when_event_offer
    { type: 'EventOffer' }
  end

  def when_network_offer
    { type: 'NetworkOffer' }
  end

  def when_event_offers_private
    { event_info: { is_private: true } }
  end

  def when_event_offers_public
    { event_info: { is_private: false } }
  end

  def when_offer_variants_active
    { status: OfferVariant.status_considered_active }
  end

  def when_offer_variants_active_public
    { status: OfferVariant.status_considered_active_public }
  end

  def when_offer_variants_positive(include_paused = false)
    statuses = OfferVariant.status_considered_positive
    { status: include_paused ? statuses | [OfferVariant.status_paused] : statuses }
  end

  def when_offer_variants_private
    { status: OfferVariant.status_active_private }
  end

  def when_offer_variants_public
    { status: OfferVariant.status_considered_public }
  end

  def when_offer_variants_negative
    { status: OfferVariant.status_considered_negative }
  end

  def when_offer_variants_suspended
    { status: OfferVariant.status_suspended }
  end

  def when_image_creatives_active
    { status: ImageCreative.status_active }
  end

  def when_text_creatives_active
    { status: TextCreative.status_active }
  end

  def when_stats_not_beyond_referral
    { status: Order.statuses - [Order.status_beyond_referral_period] + [nil] }
  end

  def when_stats_beyond_referral_acceptable
    return {} unless user.is_a?(Affiliate)

    { status: Order.status_beyond_referral_period, approval: AffiliateStat.approvals_publishable }
  end

  def when_chat_participant_is_me
    { participant_id: user.id, participant_type: user.class.name }
  end

  def when_conversion_is_meaningless
    if user.is_a?(Affiliate)
      { conversions: 1, affiliate_pay: [nil, 0] }
    elsif user.is_a?(Network)
      { conversions: 1, order_total: [nil, 0], true_pay: [nil, 0] }
    else
      {}
    end
  end
end
