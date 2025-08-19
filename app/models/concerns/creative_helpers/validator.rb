module CreativeHelpers::Validator
  class DuplicateTextCreativeName < ActiveModel::Validator
    def validate(record)
      return unless record.offer_variants.present? && record.offer_variants.first.offer.text_creatives.present?

      names = record.offer_variants.first.offer.text_creatives.map(&:creative_name)
      return unless names.include?(record.creative_name)

      record.errors.add(:creative_name, record.errors.generate_message(:creative_name, :taken))
    end
  end

  class DestinationUrlMatchDomain < ActiveModel::Validator
    def validate(record)
      offer = record.offer_variants.first.offer

      return unless offer&.deeplinkable?
      return unless to_examine = record[:client_url].presence

      return if offer.destination_match?(to_examine)

      record.errors.add(:client_url, :does_not_match)
    end
  end
end
