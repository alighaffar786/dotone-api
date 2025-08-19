class Teams::TermSerializer < ApplicationSerializer
  attributes :id, :text

  has_many :text_translations
end
