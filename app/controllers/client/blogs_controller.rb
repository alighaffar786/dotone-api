class Client::BlogsController < Client::BaseController
  before_action :set_page, :set_blog, :set_nav

  def index
    @blog_contents = @blog.blog_contents.paginate(page: params[:page])
    @authors = @blog.authors_with_published_contents.distinct
    @blog_tags = @blog.ordered_blog_tags
    @blog_pages = @blog.blog_pages_with_published_contents
  end

  def tag
    render :index
  end

  def page
    render :index
  end

  def show
    @blog_content = @blog.blog_contents.with_slug(params[:slug]).first
    @related_blog_contents = @blog_content.related_contents(3)
  end

  private

  def set_page
    @page = :blog
  end

  def set_blog
    @blog = Blog.with_path(request.path).first
  end

  def set_nav
    @nav = :beta
  end
end
