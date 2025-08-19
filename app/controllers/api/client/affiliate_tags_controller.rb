class Api::Client::AffiliateTagsController < Api::Client::BaseController
  load_and_authorize_resource only: :index

  def index
    @affiliate_tags = paginate(AffiliateTagCollection.new(@affiliate_tags, params).collect)
    respond_with_pagination @affiliate_tags, tag_type: params[:tag_type]
  end

  def media_categories
    authorize! :read, AffiliateTag
    @affiliate_tags = query_media_categories
    respond_with @affiliate_tags, each_serializer: AffiliateTag::MediaCategorySerializer, children: include_children?
  end

  def target_devices
    authorize! :read, AffiliateTag
    @affiliate_tags = query_target_devices
    respond_with @affiliate_tags
  end

  def event_media_categories
    authorize! :read, AffiliateTag
    @affiliate_tags = query_event_media_categories
    respond_with @affiliate_tags
  end

  private

  def query_media_categories
    collection = AffiliateTagCollection.new(current_ability, params).collect.media_categories.preload(:parent_category)
    collection = collection.preload(:child_categories) if include_children?
    collection
  end

  def query_target_devices
    AffiliateTagCollection.new(current_ability, params).collect.target_devices
  end

  def query_event_media_categories
    AffiliateTagCollection.new(current_ability, params).collect.event_media_categories
  end

  def include_children?
    truthy?(params[:children])
  end
end
