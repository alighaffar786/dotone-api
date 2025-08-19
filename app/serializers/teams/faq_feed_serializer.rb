class Teams::FaqFeedSerializer < ApplicationSerializer
  attributes :id, :title, :content, :role, :published, :category

  has_many :title_translations
  has_many :content_translations
end
