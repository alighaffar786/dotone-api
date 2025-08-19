class Api::Client::Teams::BlogPagesController < Api::Client::Teams::BaseController
  load_and_authorize_resource :blog
  load_and_authorize_resource through: :blog, shallow: true

  def index
    @blog_pages = paginate(@blog_pages)
    respond_with_pagination @blog_pages
  end

  def create
    if @blog_page.save
      respond_with @blog_page
    else
      respond_with @blog_page, status: :unprocessable_entity
    end
  end

  def update
    if @blog_page.update(blog_page_params)
      respond_with @blog_page
    else
      respond_with @blog_page, status: :unprocessable_entity
    end
  end

  private

  def blog_page_params
    params.require(:blog_page).permit(:blog_id, :name, :description)
  end
end
