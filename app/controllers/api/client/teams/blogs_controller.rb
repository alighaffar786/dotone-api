class Api::Client::Teams::BlogsController < Api::Client::Teams::BaseController
  load_and_authorize_resource

  def index
    respond_with @blogs
  end

  def create
    if @blog.save
      respond_with @blog
    else
      respond_with @blog, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      respond_with @blog
    else
      respond_with @blog, status: :unprocessable_entity
    end
  end

  def get_sites
    authorize! :read, SkinMap
    respond_with SkinMap.all
  end

  private

  def blog_params
    params.require(:blog).permit(:name, :path, :skin_map_id)
  end
end
