# Show blog content tag

module ConverlyHelper::BlogHelpers
  class BlogContentTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, params, context)
      context.define_tag 'blog_content' do |tag|
        tag.expand
      end

      [
        :author_name,
        :author_avatar_url,
        :title,
        :html,
        :status,
        :image_url,
        :page_name,
        :posted_date,
        :posted_date_number,
        :posted_month_name,
        :posted_month_name_short,
        :posted_month_number,
        :posted_year,
        :content_link,
        :content_path,
        :page_link,
        :page_path,
        :short_description,
      ].each do |attribute|
        context.define_tag "blog_content:#{attribute}" do |tag|
          obj = tag.locals.blog_content || obtain_blog_content(skin_map, path, params[:page_slug],
            params[:content_slug])
          obj.send(attribute) if obj.respond_to?(attribute)
        end
      end

      context.define_tag 'blog_content:author' do |tag|
        contents = []
        obj = tag.locals.blog_content || obtain_blog_content(skin_map, path, params[:page_slug], params[:content_slug])
        if obj.author.present?
          tag.locals.author = obj.author
          contents << tag.expand
        end
        contents.join
      end

      context.define_tag 'blog_content:related' do |tag|
        contents = []
        size = tag.attr['limit'] || 5
        obj = tag.locals.blog_content || obtain_blog_content(skin_map, path, params[:page_slug], params[:content_slug])
        obj.related_contents(size).each do |related_content|
          tag.locals.related_content = related_content
          contents << tag.expand
        end
        contents.join
      end

      context.define_tag 'blog_content:blog' do |tag|
        contents = []
        blog = obtain_blog(skin_map, path)
        tag.locals.blog = blog
        contents << tag.expand
        contents.join
      end

      context.define_tag 'blog_content:blog_tags' do |tag|
        contents = []
        obj = tag.locals.blog_content || obtain_blog_content(skin_map, path, params[:page_slug], params[:content_slug])
        obj.blog_tags.each do |blog_tag|
          tag.locals.blog_tag = blog_tag
          contents << tag.expand
        end
        contents.join
      end

      related_content = nil

      context.define_tag 'related_content',
        for: related_content,
        expose: [
          :title,
          :short_description,
          :author_name,
          :author_avatar_url,
          :image_url,
          :posted_date,
          :posted_date_number,
          :posted_month_name,
          :posted_month_name_short,
          :posted_month_number,
          :posted_year,
          :content_path,
        ]
    end
  end
end
