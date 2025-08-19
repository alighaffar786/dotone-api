# Show author information

module ConverlyHelper::BlogHelpers
  class AuthorTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, _params, context)
      context.define_tag 'author' do |tag|
        tag.expand
      end

      context.define_tag 'author:full_name' do |tag|
        tag.locals.author.full_name
      end

      context.define_tag 'author:avatar_url' do |tag|
        tag.locals.author.avatar_cdn_url
      end

      context.define_tag 'author:page_url' do |tag|
        blog = Blog.where(skin_map_id: skin_map.id, path: path).last rescue nil
        tag.locals.author.blog_page_url(blog)
      end

      context.define_tag 'related_author' do |tag|
        tag.expand
      end

      context.define_tag 'related_author:full_name' do |tag|
        tag.locals.author.full_name
      end

      context.define_tag 'related_author:avatar_url' do |tag|
        tag.locals.author.avatar_cdn_url
      end

      context.define_tag 'related_author:page_url' do |tag|
        blog = Blog.where(skin_map_id: skin_map.id, path: path).last rescue nil
        tag.locals.author.blog_page_url(blog)
      end
    end
  end
end
