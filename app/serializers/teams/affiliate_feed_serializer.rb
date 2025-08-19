class Teams::AffiliateFeedSerializer < Base::AffiliateFeedSerializer
  attributes :id, :title, :sticky, :sticky_until, :sticky_expired?, :published_at, :republished_at, :content, :status,
    :feed_type, :role, :country_ids

  has_many :title_translations
  has_many :content_translations
  has_many :countries
end
