class FaqFeedSerializer < ApplicationSerializer
  translatable_attributes(*FaqFeed.dynamic_translatable_attributes)

  attributes :id, :title, :content, :category
end
