class ClickStat
  attr_accessor :id, :offer_variant_id, :affiliate_id, :affiliate_stat, :channel_id, :campaign_id, :affiliate_offer_id, :offer_id

  def self.interpolate(str, params = {})
    return if str.blank?

    str
      .gsub(TOKEN_SERVER_SUBID, params[:server_subid].presence.to_s)
      .gsub(TOKEN_SOURCE_ID, params[:source_id].presence.to_s)
  end

  def initialize(args = {})
    @id = args[:id]
    @offer_variant_id = args[:offer_variant_id]
    @offer_id = args[:offer_id]
    @affiliate_id = args[:affiliate_id]
    @affiliate_offer_id = args[:affiliate_offer_id]
    @channel_id = args[:channel_id]
    @campaign_id = args[:campaign_id]
    @v2 = args[:v2]

    # Add all the necessary attributes
    # for tokenization during click redirection
    # here
    attributes = args.slice(
      :subid_1,
      :subid_2,
      :subid_3,
      :subid_4,
      :subid_5,
      :channel_id,
      :campaign_id,
      :aff_uniq_id,
      :ios_uniq,
      :android_uniq,
      :gaid,
      :http_referer,
    )

    @affiliate_stat = AffiliateStat.new(attributes)

    # Need to assign transaction id this way since
    # attribute `id` is protected from mass-assignment
    affiliate_stat.id = args[:id]
  end

  def entity
    offer_variant
  end

  def affiliate
    @affiliate ||= Affiliate.cached_find(affiliate_id)
  end

  def offer_variant
    @offer_variant ||= OfferVariant.cached_find(offer_variant_id)
  end

  def campaign
    @campaign ||= Campaign.cached_find(campaign_id)
  end

  def affiliate_offer
    @affiliate_offer ||= Affiliate.cached_find(affiliate_offer_id)
  end

  def offer
    @offer ||= offer_variant&.cached_offer || Offer.cached_find(offer_id)
  end

  def to_s
    id
  end

  def to_stat
    affiliate_stat
  end

  def v2?
    @v2 == true
  end

  def url
    return if entity.blank?

    ClickStat.interpolate(
      entity.destination_url, { server_subid: id, source_id: affiliate&.id }
    )
  end
end
