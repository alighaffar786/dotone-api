# frozen_string_literal: true

class ChatbotStepSerializer < ApplicationSerializer
  translatable_attributes(*ChatbotStep.dynamic_translatable_attributes)

  attributes :id, :title, :content, :keywords
end
