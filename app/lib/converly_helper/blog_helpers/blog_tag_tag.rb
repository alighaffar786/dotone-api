# Show blog tag information

module ConverlyHelper::BlogHelpers
  class BlogTagTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, _params, context)
      context.define_tag 'blog_tag' do |tag|
        tag.expand
      end

      context.define_tag 'blog_tag:name' do |tag|
        tag.locals.blog_tag.name
      end

      context.define_tag 'blog_tag:blog_tag_path' do |tag|
        blog = obtain_blog(skin_map, path)
        tag.locals.blog_tag.blog_tag_path(blog)
      end
    end
  end
end
