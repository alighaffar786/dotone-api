class Teams::BlogContentSerializer < ApplicationSerializer
  attributes :id, :title, :html, :slug, :status, :posted_at, :short_description, :image_url, :content_path,
    :tag_names, :blog_page_ids, :blog_image_id

  has_one :author, serializer: Teams::AffiliateUser::MiniSerializer
end
