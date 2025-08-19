class Affiliates::PopupFeedSerializer < ApplicationSerializer
  translatable_attributes(*PopupFeed.dynamic_translatable_attributes)

  attributes :id, :cdn_url, :url, :title, :button_label
end
