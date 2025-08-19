module HasBlogAuthor
  extend ActiveSupport::Concern

  def blog_page_url(blog)
    ['/', blog.path, "/author/a-#{self.class.name}-", "#{id}.html"].compact_blank.join
  end

  def blog_tags(blog)
    blog_contents = BlogContent.where(author_id: id, author_type: self.class.name).with_blogs([blog])
    blog_contents.flat_map(&:blog_tags).uniq
  end
end
