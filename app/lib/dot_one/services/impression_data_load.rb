##
# Class represents a creative ready
# for impression request. Any detailed
# info about the request will be stored
# in its data_set.
# uri will be set to an image URL for
# image creative or 1x1 pixel for other type
# of creatives
class DotOne::Services::ImpressionDataLoad
  attr_accessor :data_set, :uri

  def initialize(creative)
    return if creative.blank?

    @data_set = []

    @uri = if creative.is_a?(ImageCreative)
      URI.parse(creative.cdn_url)
    else
      URI.parse('https://cdn.adotone.com/adslots/1x1.gif')
    end

    id_label = [creative.class.to_s.underscore, 'id'].join('_')

    @data_set = URI.decode_www_form(@uri.query.to_s)

    @data_set << ['wl', DotOne::Setup.wl_id]
    @data_set << [id_label, creative.id]
    @data_set
  end

  def add_offer_variant(offer_variant)
    return false if offer_variant.blank?

    @data_set << ['offer_id', offer_variant.offer_id]
    @data_set << ['offer_variant_id', offer_variant.id]
    @data_set << ['network_id', offer_variant.cached_offer.network_id]
    @data_set
  end

  def add_affiliate_offer(affiliate_offer)
    return false if affiliate_offer.blank?

    @data_set << ['affiliate_offer_id', affiliate_offer.id]
    @data_set
  end

  def add_affiliate(affiliate)
    return false if affiliate.blank?

    @data_set << ['affiliate_id', affiliate.id]
  end

  def add_ad_slot(ad_slot)
    return false if ad_slot.blank?

    @data_set << ['ad_slot_id', ad_slot.id]
    @data_set
  end

  def to_s
    @uri.query = URI.encode_www_form(@data_set)
    @uri.to_s
  end
end
