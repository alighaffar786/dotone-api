class Teams::AffiliateStatSerializer < Teams::AffiliateStat::IndexSerializer
  class OfferVariantSerializer < Base::OfferVariantSerializer
    attributes :id, :full_name, :status
  end

  class AffiliateOfferSerializer < Base::AffiliateOfferSerializer
    attributes :id, :offer_id, :affiliate_id, :approval_status
  end

  class ConversionStepSerializer < Base::ConversionStepSerializer
    attributes :id, :on_past_due, :name

    has_one :true_currency
  end

  attributes :clicks, :offer_variant_id, :text_creative_id, :image_creative_id, :manual_notes, :affiliate_offer_id,
    :geo_location, :android_uniq, :ios_uniq, :device_os, :device_os_version, :forex, :conversion_step_snapshots, :status,
    :conversion_step_id, :real_true_pay, :transaction_locked?

  original_attributes :true_pay, :affiliate_pay, :order_total

  has_one :offer_variant, serializer: OfferVariantSerializer, if: :can_read_offer_variant?
  has_one :affiliate_offer, serializer: AffiliateOfferSerializer, if: :can_read_affiliate_offer?
  has_one :image_creative, serializer: Teams::ImageCreative::MiniSerializer, if: :can_read_image_creative?
  has_one :text_creative, serializer: Teams::TextCreative::MiniSerializer, if: :can_read_text_creative?
  has_one :conversion_step, serializer: ConversionStepSerializer, if: :can_read_conversion_step?

  def forex
    object.forex || object.copy_stats.where.not(forex: nil).first&.forex
  end

  def conversion_step_id
    object.conversion_step&.id
  end
end
