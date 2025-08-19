# Show author page information

module ConverlyHelper::BlogHelpers
  class AuthorPageTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, params, context)
      context.define_tag 'author_page' do |tag|
        tag.locals.author = obtain_author(params)
        tag.expand
      rescue Exception => e
        ::Rails.logger.error "[ConverlyHelper::BlogHelpers::AuthorPageTag#initialize] #{e.message} #{e.backtrace}"
      end

      context.define_tag 'author:full_name' do |tag|
        tag.locals.author.full_name
      end

      context.define_tag 'author:avatar_url' do |tag|
        tag.locals.author.avatar_cdn_url
      end

      context.define_tag 'author:page_url' do |tag|
        blog = obtain_blog(skin_map, path)
        tag.locals.author.blog_page_url(blog)
      end

      context.define_tag 'author:blog_tags' do |tag|
        contents = []
        blog = obtain_blog(skin_map, path)
        tag.locals.author.blog_tags(blog).each do |blog_tag|
          tag.locals.blog_tag = blog_tag
          contents << tag.expand
        end
        contents.join
      end
    end
  end
end
