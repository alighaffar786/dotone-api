class Api::Client::Teams::BlogContentsController < Api::Client::Teams::BaseController
  load_and_authorize_resource :blog_page, only: :index
  load_and_authorize_resource through: :blog_page, only: :index
  load_and_authorize_resource except: :index

  def index
    @blog_contents = paginate(query_index)
    respond_with_pagination @blog_contents
  end

  def create
    @blog_content.author = current_user

    if @blog_content.save
      respond_with @blog_content
    else
      respond_with @blog_content, status: :unprocessable_entity
    end
  end

  def update
    if @blog_content.update(blog_content_params)
      respond_with @blog_content
    else
      respond_with @blog_content, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog_content.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    BlogContentCollection.new(@blog_contents, params)
     .collect
     .preload(:author, :blog_image, :main_blog, :main_page, :blog_tags)
  end

  def blog_content_params
    params
      .require(:blog_content)
      .permit(
        :title, :slug, :short_description, :status, :posted_at, :html,
        :blog_image_id, tag_names: [], blog_page_ids: [],
      )
  end
end
