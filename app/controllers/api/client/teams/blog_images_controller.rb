class Api::Client::Teams::BlogImagesController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with_pagination paginate(query_index)
  end

  def create
    if @blog_image.save
      respond_with @blog_image
    else
      respond_with @blog_image, status: :unprocessable_entity
    end
  end

  def update
    if @blog_image.update(blog_image_params)
      respond_with @blog_image
    else
      respond_with @blog_image, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog_image.destroy
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def query_index
    BlogImageCollection.new(current_ability, params).collect
  end

  def blog_image_params
    params.require(:blog_image).permit(:cdn_url, :width, :height)
  end
end
