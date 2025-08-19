class Api::Client::Teams::FaqFeedsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with query_index, meta: { t_columns: FaqFeed.dynamic_translatable_attribute_types }
  end

  def create
    if @faq_feed.save
      respond_with @faq_feed
    else
      respond_with @faq_feed, status: :unprocessable_entity
    end
  end

  def update
    if @faq_feed.update(faq_feed_params)
      respond_with @faq_feed
    else
      respond_with @faq_feed, status: :unprocessable_entity
    end
  end

  def destroy
    if @faq_feed.destroy
      head :no_content
    else
      respond_with @faq_feed, status: :unprocessable_entity
    end
  end

  def sort
    authorize! :update, FaqFeed
    @faq_feeds = @faq_feeds
      .with_roles(params[:role])
      .where(id: params[:ids])
      .order(Arel.sql("FIELD(id, #{params[:ids].join(',')})"))

    @faq_feeds.each do |faq|
      faq.update(ordinal: params[:ids].index(faq.id))
    end

    head 200
  end

  private

  def faq_feed_params
    params
      .require(:faq_feed)
      .permit(
        :title, :content, :published, :role, :category,
        translations_attributes: [:id, :locale, :field, :content],
      )
  end

  def query_index
    @faq_feeds
      .preload_translations(:title, :content)
      .with_roles(params[:role])
      .order(ordinal: :asc)
  end
end
