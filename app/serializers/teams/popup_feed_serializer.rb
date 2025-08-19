class Teams::PopupFeedSerializer < ApplicationSerializer
  attributes :id, :title, :button_label, :cdn_url, :url, :published, :start_date, :end_date

  has_many :title_translations
  has_many :button_label_translations
end
