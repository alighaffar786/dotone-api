class Affiliates::EventOfferSerializer < Base::EventOfferSerializer
  class EventInfoSerilalizer < Base::EventInfoSerializer
    class RelatedOfferSerializer < Base::NetworkOfferSerializer
      attributes :id, :commissions, :approval_message
    end

    attributes :is_private, :quota, :applied_by, :selection_by, :submission_by, :evaluation_by, :published_by,
      :active_timeline, :details, :event_requirements, :instructions, :keyword_requirements, :is_supplement_needed,
      :supplement_notes, :is_address_needed, :event_contract, :coordinator_email, :fulfillment_type,
      :value, :event_type, :availability_type, :popularity_unit, :popularity

    has_many :category_groups
    has_many :images

    has_one :related_offer, serializer: RelatedOfferSerializer
    has_one :event_media_category
    has_one :media_category
  end

  attributes :id, :name, :brand_image_url, :short_description, :published_date, :affiliate_pay_flexible?, :affiliate_pay,
    :max_affiliate_pay, :total_value, :approval_message

  has_many :categories
  has_many :countries
  has_many :terms

  has_one :event_info, serializer: EventInfoSerilalizer
  has_one :default_offer_variant, key: :offer_variant, serializer: Affiliates::OfferVariant::MiniSerializer
end
