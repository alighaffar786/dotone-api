class V2::Affiliates::AffiliateStatSerializer < Base::AffiliateStatSerializer
  attributes :id, :unique_id, :recorded_at, :captured_at, :published_at, :updated_at, :offer_id, :offer_name, :converted_at,
    :offer_variant_id, :affiliate_id, :commission, :conversions, :order_number, :order_total, :subid_1, :subid_2,
    :subid_3, :subid_4, :subid_5, :aff_uniq_id, :conversion_name, :step_label, :step_name, :conversion_type, :approval

  def unique_id
    copy_stat_id
  end

  def offer_name
    object.offer&.t_name
  end

  def conversion_name
    object.step_label || object.step_name
  end

  def conversion_type
    object.affiliate_conv_type
  end
end
