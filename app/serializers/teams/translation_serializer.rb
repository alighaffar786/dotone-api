class Teams::TranslationSerializer < ApplicationSerializer
  attributes :id, :locale, :field, :content
end
