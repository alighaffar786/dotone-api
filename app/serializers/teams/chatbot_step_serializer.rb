# frozen_string_literal: true

class Teams::ChatbotStepSerializer < ApplicationSerializer
  attributes :id, :title, :content, :keywords, :role

  has_many :title_translations
  has_many :content_translations
  has_many :keywords_translations
end
