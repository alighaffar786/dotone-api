# Show certain blog page and its exposed
# information

module ConverlyHelper::BlogHelpers
  class BlogPageTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, params, context)
      context.define_tag 'blog_page' do |tag|
        tag.expand
      end

      context.define_tag 'blog_page:name' do |tag|
        obj = tag.locals.blog_page || obtain_blog_page(skin_map, path, params[:page_slug])
        obj.name if obj.respond_to?(:name)
      end

      context.define_tag 'blog_page:description' do |tag|
        obj = tag.locals.blog_page || obtain_blog_page(skin_map, path, params[:page_slug])
        obj.description if obj.respond_to?(:description)
      end

      context.define_tag 'blog_page:content_count' do |tag|
        obj = tag.locals.blog_page || obtain_blog_page(skin_map, path, params[:page_slug])
        obj.content_count if obj.respond_to?(:content_count)
      end

      context.define_tag 'blog_page:page_path' do |tag|
        obj = tag.locals.blog_page || obtain_blog_page(skin_map, path, params[:page_slug])
        obj.page_path if obj.respond_to?(:page_path)
      end

      context.define_tag 'blog_page:authors' do |tag|
        contents = ''
        blog_page = obtain_blog_page(skin_map, path, params[:page_slug])

        blog_page.authors.each do |author|
          tag.locals.author = author
          contents << tag.expand
        end
        contents
      end

      context.define_tag 'blog_page:blog_tags' do |tag|
        contents = []
        blog_page = obtain_blog_page(skin_map, path, params[:page_slug])

        blog_page.blog_tags.each do |blog_tag|
          tag.locals.blog_tag = blog_tag
          contents << tag.expand
        end
        contents.join
      end
    end
  end
end
