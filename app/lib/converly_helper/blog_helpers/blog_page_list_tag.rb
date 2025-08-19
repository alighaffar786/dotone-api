# Listing out blog page list based on
# certain parameters from tag

module ConverlyHelper::BlogHelpers
  class BlogPageListTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, _params, context)
      ##
      # Print out recent blog content list belongs to
      # all pages
      context.define_tag 'blog_page_list_with_count' do |tag|
        contents = []

        blog = tag.locals.blog

        blog = obtain_blog(skin_map, path) if blog.blank?

        if blog.present?
          blog_pages = blog.blog_pages_with_published_contents

          (blog_pages || []).each do |bp|
            tag.locals.blog_page = bp
            contents << tag.expand
          end
        end

        contents.join
      end
    end
  end
end
