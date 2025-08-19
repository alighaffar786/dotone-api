# Show author information

module ConverlyHelper::BlogHelpers
  class BlogTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, _params, context)
      context.define_tag 'blog' do |tag|
        tag.expand
      end

      context.define_tag 'blog:blog_tags' do |tag|
        blog = tag.locals.blog
        limit = tag.attr['limit'] || 15

        blog = obtain_blog(skin_map, path) if blog.blank?

        contents = []

        if blog.present?
          blog.cached_ordered_blog_tags(limit).each do |blog_tag|
            tag.locals.blog_tag = blog_tag
            contents << tag.expand
          end
        end

        contents.join
      end

      context.define_tag 'blog:authors' do |tag|
        blog = obtain_blog(skin_map, path)

        blog = tag.locals.blog if tag.locals.blog.present?

        contents = []
        if blog.present?
          blog.authors_with_published_contents.distinct.each do |author|
            tag.locals.author = author
            contents << tag.expand
          end
        end
        contents.join
      end
    end
  end
end
