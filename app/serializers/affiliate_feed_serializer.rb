class AffiliateFeedSerializer < Base::AffiliateFeedSerializer
  attributes :id, :sticky, :published_at, :title, :content, :feed_type, :role

  def content
    object.formatted_content
  end

  def title
    object.t_title
  end

  def sticky
    !object.sticky_expired? && object.sticky?
  end
end
