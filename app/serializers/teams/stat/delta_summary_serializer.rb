class Teams::Stat::DeltaSummarySerializer < Base::AffiliateStatSerializer
  class AffiliateSerializer < Base::AffiliateSerializer
    attributes :id
    attribute :name, if: :can_read_affiliate?
  end

  attributes :delta_amount, :delta_percentage, :total_true_pay

  conditional_attributes :affiliate_id, if: :affiliate_requested?
  conditional_attributes :offer_id, if: :offer_requested?

  has_one :affiliate, serializer: AffiliateSerializer, if: :affiliate_requested?
  has_one :offer, serializer: Teams::NetworkOffer::MiniSerializer, if: :offer_requested?

  def affiliate_requested?
    instance_options[:affiliates].present?
  end

  def offer_requested?
    instance_options[:offers].present?
  end

  def offer
    instance_options[:offers][object.offer_id] || object.offer
  end

  def affiliate
    instance_options[:affiliates][object.affiliate_id] || object.affiliate
  end
end
