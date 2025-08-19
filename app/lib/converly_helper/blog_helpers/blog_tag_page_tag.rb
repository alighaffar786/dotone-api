# Show blog tag page information

module ConverlyHelper::BlogHelpers
  class BlogTagPageTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, params, context)
      blog_tag = obtain_blog_tag(params)

      context.define_tag 'blog_tag_page' do |tag|
        tag.locals.blog_tag = blog_tag
        tag.expand
      rescue Exception => e
        ::Rails.logger.error "[ConverlyHelper::BlogHelpers::BlogTagPageTag#initialize] #{e.message} #{e.backtrace}"
      end

      context.define_tag 'blog_tag_page:name' do |tag|
        tag.locals.blog_tag.name
      end

      context.define_tag 'blog_tag_page:authors' do |tag|
        contents = []
        blog = obtain_blog(skin_map, path)
        authors = blog_tag.blog_contents
          .blog_joins
          .with_blogs([blog])
          .map(&:author)
        authors.each do |author|
          tag.locals.author = author
          contents << tag.expand
        end
        contents.join
      end
    end
  end
end
