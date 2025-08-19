class Teams::OfferCapSerializer < ApplicationSerializer
  local_time_attributes(:earliest_at)

  attributes :id, :offer_id, :offer_variant_id, :cap_type, :number, :conversion_so_far, :earliest_at, :total_cap_allocated

  def total_cap_allocated
    if instance_options[:total_cap_allocated]
      instance_options[:total_cap_allocated][object.offer_id]
    else
      object.offer.cap_allocated
    end
  end
end
