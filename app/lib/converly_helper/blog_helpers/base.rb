# Listing out blog list based on
# certain parameters from tag

module ConverlyHelper::BlogHelpers
  class Base
    private

    def obtain_author(params)
      klass = params[:author_type].constantize
      klass.find(params[:author_id])
    end

    def obtain_blog(skin_map, path)
      skin_map.blogs.where(path: path).last
    end

    def obtain_blog_page(skin_map, path, page_slug)
      blog = obtain_blog(skin_map, path)
      return unless blog.present?

      blog.cached_blog_page_with_slug(page_slug)
    end

    def obtain_blog_content(skin_map, path, page_slug, content_slug)
      blog_contents = nil

      blog = obtain_blog(skin_map, path)

      return if blog.blank?

      if content_slug.present?
        # Handle the new format where slug is preceded by
        # its blog content id
        blog_contents = BlogContent
          .with_blogs([blog])
          .where(blog_contents: { id: content_slug.to_i })
          .published

        if blog_contents.blank?
          blog_contents = BlogContent
            .with_blogs([blog])
            .with_slug(content_slug)
            .published
        end
      end

      blog_page = obtain_blog_page(skin_map, path, page_slug)

      if blog_contents.blank? && blog_page.present?
        blog_contents = BlogContent
          .with_blogs([blog])
          .with_blog_pages([blog_page])
          .index_page
      end

      if blog_contents.blank?
        blog_contents = BlogContent
          .with_blogs([blog])
          .home_page
      end

      blog_contents.present? ? blog_contents.last : nil
    end

    def obtain_blog_tag(params)
      AffiliateTag.find(params[:tag]) rescue nil
    end
  end
end
