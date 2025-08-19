# frozen_string_literal: true

class Teams::ChatbotSearchLogSerializer < ApplicationSerializer
  attributes :id, :keyword, :owner_type, :locale, :updated_at

  has_one :owner

  def self.serializer_for(model, options)
    case model.class.name
    when 'Affiliate'
      Teams::Affiliate::MiniSerializer
    when 'Network'
      Teams::Network::MiniSerializer
    else
      super
    end
  end
end
