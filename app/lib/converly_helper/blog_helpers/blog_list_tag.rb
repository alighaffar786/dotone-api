# Listing out blog list based on
# certain parameters from tag

module ConverlyHelper::BlogHelpers
  class BlogListTag < ConverlyHelper::BlogHelpers::Base
    def initialize(skin_map, path, params, context)
      ##
      # Print out recent blog content list belongs to
      # all pages
      context.define_tag 'blog_recent_list_for_all' do |tag|
        DotOne::Cache.fetch(DotOne::Utils.to_cache_key(
          [BlogContent],
          params,
          current_user_type,
          current_user,
          current_user_locale,
          :blog_recent_list_for_all,
        )) do

          contents = []

          path = tag.attr['path'] if tag.attr['path'].present?

          limit = tag.attr['limit']

          blog = obtain_blog(skin_map, path)

          if blog.present?
            blog_contents = blog.blog_contents
              .published
              .recent
              .limit(limit)

            blog_contents.each do |bc|
              tag.locals.blog_content = bc
              contents << tag.expand
            end
          end

          contents.join
        end
      end

      ##
      # Print out recent blog content list belongs to
      # certain page based on the page_slug
      context.define_tag 'blog_recent_list_for_page' do |tag|
        contents = []

        limit = tag.attr['limit']

        blog = obtain_blog(skin_map, path)

        if blog.present? && params[:page_slug]
          blog_pages = blog.blog_pages
            .with_slug(params[:page_slug])

          blog_page = (blog_pages.first if blog_pages.present?)

          if blog_page.present?
            blog_contents = blog_page.blog_contents
              .published
              .recent
              .limit(limit)

            blog_contents.each do |bc|
              tag.locals.blog_content = bc
              contents << tag.expand
            end
          end
        end

        contents.join
      end

      ##
      # Print out recent blog content list belongs to
      # certain author based on the page_slug
      context.define_tag 'blog_recent_list_for_author' do |tag|
        contents = []

        limit = tag.attr['limit']

        blog = obtain_blog(skin_map, path)

        author = obtain_author(params)

        if author.present?
          blog_contents = author.blog_contents
            .blog_joins
            .with_blogs([blog])
            .published
            .recent
            .limit(limit)

          blog_contents.each do |bc|
            tag.locals.blog_content = bc
            contents << tag.expand
          end
        end

        contents.join
      end

      ##
      # Print out recent blog content list belongs to
      # certain tag based on the tag on params
      context.define_tag 'blog_recent_list_for_tag' do |tag|
        contents = []

        limit = tag.attr['limit']

        blog = obtain_blog(skin_map, path)

        blog_tag = obtain_blog_tag(params)

        if blog_tag.present?
          blog_contents = blog_tag.blog_contents
            .blog_joins
            .with_blogs([blog])
            .published
            .recent
            .limit(limit)

          blog_contents.each do |bc|
            tag.locals.blog_content = bc
            contents << tag.expand
          end
        end

        contents.join
      end
    end
  end
end
