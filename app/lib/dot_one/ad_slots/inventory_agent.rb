##
# This class is responsible to pick up all the
# eligible ad feeds to be deliver to delivery agent.

class DotOne::AdSlots::InventoryAgent
  attr_accessor :ad_slot, :category_group_ids, :offer_ids, :affiliate_id, :text_creative_id, :affiliate, :inventories

  def initialize(ad_slot)
    @ad_slot = ad_slot

    @affiliate = ad_slot.cached_affiliate
    @affiliate = DotOne::Setup.missing_credit_affiliate unless @affiliate&.active?

    @affiliate_id = @affiliate&.id
    @text_creative_id = ad_slot.text_creative_id
    @category_group_ids = ad_slot.cached_category_groups.map(&:id)
    @offer_ids = ad_slot.cached_offers.map(&:id)

    @inventories = []
  end

  ##
  # Generate inventories that are ready
  # to be delivered to ad slots
  def generate_inventories
    return [] unless affiliate&.active?

    @inventories = generate_step_1
    return @inventories if @inventories.size >= 4

    @inventories += generate_step_2
    return @inventories if @inventories.size >= 4

    @inventories += generate_step_3
    @inventories
  end

  # Generate inventories from native ads (text creatives)
  def generate_step_1
    text_creatives = TextCreative.inventories(
      affiliate_id: affiliate_id,
      category_group_ids: category_group_ids,
      offer_ids: offer_ids,
      text_creative_ids: [text_creative_id].compact_blank,
    )

    build_inventories(text_creatives, :specific)
  end

  # Generate inventories from auto-approvable offers
  def generate_step_2
    text_creatives = TextCreative.auto_approvable_inventories(
      affiliate_id: affiliate_id,
      category_group_ids: category_group_ids,
      offer_ids: offer_ids,
    )

    build_inventories(text_creatives, :general)
  end

  # Generate inventories from catch-all
  def generate_step_3
    text_creatives = TextCreative.catch_all_inventories
    build_inventories(text_creatives, :general)
  end

  private

  def specific?(creative)
    (category_group_ids & creative.cached_category_groups.map(&:id)).present? ||
    offer_ids.include?(creative.cached_offer.id) ||
    text_creative_id == creative.id
  end

  def build_inventories(text_creatives, build_criteria = :general)
    creative_ids = text_creatives.pluck('text_creatives.id').uniq.sample(10)
    creative_ids.map do |creative_id|
      creative = TextCreative.cached_find(creative_id)
      affiliate_offer = AffiliateOffer.best_match(affiliate, creative.cached_offer)

      if affiliate_offer.blank? || affiliate_offer.active? || affiliate_offer.cancelled?
        if build_criteria == :specific
          text_hash(creative, affiliate_offer) if specific?(creative)
        else
          text_hash(creative, affiliate_offer)
        end
      end
    end
    .compact_blank
  end

  def text_hash(creative, affiliate_offer)
    data_load = DotOne::Services::ImpressionDataLoad.new(creative)
    data_load.add_offer_variant(creative.cached_offer_variant)
    data_load.add_affiliate_offer(affiliate_offer) if affiliate_offer&.active?
    data_load.add_affiliate(affiliate)
    data_load.add_ad_slot(ad_slot)

    tracking_url = creative.to_tracking_url(affiliate, extra_params: { ad_slot_id: ad_slot.id || 'fallback-ad-slot' })

    {
      type: 'TextCreative',
      tracking_url: tracking_url,
      title: creative.title,
      promo_text_1: creative.content_1,
      promo_text_2: creative.content_2,
      button_text: creative.button_text,
      coupon_code: creative.coupon_code,
      original_price: format_amount(creative.original_price),
      discount_price: format_amount(creative.discount_price),
      image_url: creative.cached_image_url,
      offer_name: creative.cached_offer.t_offer_name,
      impression_url: data_load.to_s,
    }
  end

  def format_amount(amount)
    [amount.present? ? '$' : nil, amount].compact_blank.join('')
  end
end
