class Teams::EventInfoSerializer < Base::EventInfoSerializer
  original_attributes :value

  attributes :id, :popularity, :popularity_unit, :quota, :applied_by, :selection_by, :submission_by,
    :evaluation_by, :published_by, :value, :event_type, :availability_type, :fulfillment_type, :is_private,
    :related_offer_id

  conditional_attributes :coordinator_email, :is_supplement_needed, :is_address_needed, :event_contract,
    :supplement_notes, :details, :event_requirements, :instructions, :keyword_requirements,
    :is_affiliate_requirement_needed, :category_group_ids, :event_media_category_id, if: :for_event_offer_details?

  has_one :related_offer, serializer: Teams::NetworkOffer::MiniSerializer
  has_one :event_media_category

  has_many :category_groups, if: :for_event_offer_details?
  has_many :images, if: :for_event_offer_details?

  EventInfo.dynamic_translatable_attribute_types.each_key do |key|
    has_many "#{key}_translations".to_sym, if: :for_event_offer_details?
  end

  def for_event_offer_details?
    context_class == Teams::EventOfferSerializer
  end
end
