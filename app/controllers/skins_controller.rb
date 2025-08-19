class SkinsController < ActionController::Base
  include CacheHandler

  before_action :redirect_to_https
  before_action :redirect_to_asset

  def index
    mime_type = MIME::Types.type_for(file_path).first.to_s
    if File.exist?(file_path)
      if mime_type == 'text/html'
        render html: html_content.html_safe
      else
        render file: file_path, content_type: mime_type
      end
    else
      head 404
    end
  end

  private

  def file_path
    page =
      if params[:format].present? && params[:format] != 'html'
        [[params[:path], params[:format]].join('.')]
      else
        [params[:path], 'index.html']
      end
    [current_skin.public_folder, page].flatten.compact.join('/')
  end

  def html_content
    parser = Radius::Parser.new(context, tag_prefix: 'r')
    html = File.read(file_path)
    result = parser.parse(html)
    while result =~ /<r:.*>/
      result = parser.parse(result)
    end
    result
  end

  def html_partial(file)
    File.read("#{current_skin.public_folder}/#{file}")
  end

  def asset_file_request?
    ['jpg', 'gif', 'jpeg', 'png', 'js', 'css'].include?(params[:format])
  end

  def redirect_to_asset
    return unless asset_file_request?

    redirect_to file_path.sub('/app/public', '')
  end

  def redirect_to_https
    return unless current_skin.https? && request.protocol == 'http://'

    redirect_to params.permit!.merge(protocol: 'https://')
  end

  def context
    return @context if @context.present?

    @context = Radius::Context.new do |c|
      c.define_tag 'snippet' do |tag|
        key_name = tag.attr['key']
        snippet_tag = tag.attr['tag']

        # if tag ="CA" do something else if tag has params: do thebelow
        if snippet_tag.include?(':')
          #considering that tag=[param:city:bombay]
          get_user_str = snippet_tag.split(':')
          user_str = get_user_str[1]
          if params[user_str].nil? || params[user_str].to_s.blank?
            actual_tag = get_user_str[2].chomp(']') unless get_user_str[2].nil?
          else
            actual_tag = params[user_str]
          end
        else
          actual_tag = snippet_tag
        end
        tag_value = ' '
        @snippet = Snippet.find_by(snippet_key: key_name)
        tag_value = @snippet.snippet_hash[actual_tag]
        tag_value
      end

      c.define_tag 'content' do |tag|
        parse_html(html_content)
      end

      c.define_tag 'layout' do |tag|
        if tag.attr['file'] == 'false'
          @layout_file = false
        else
          @layout_file = tag.attr['file']
        end
        nil
      end

      c.define_tag 'part' do |tag|
        file = tag.attr['file']
        if tag.attr['translations'].present?
          tag.globals.translations = JSON.parse(tag.attr['translations'])
        end
        html_partial(file)
      end

      c.define_tag 'part_with_param' do |tag|
        file_path = tag.attr['file_path']
        param = params[tag.attr['attr']].gsub(/\s+/, '_') rescue nil
        postfix = tag.attr['postfix']
        postfix = "-#{postfix}" if postfix.present?
        file_name = param.downcase rescue nil
        file = "#{file_path}/#{file_name}#{postfix}.html"
        html_partial(file)
      end

      c.define_tag 'param' do |tag|
        attribute = tag.attr['attr']
        params[attribute]
      end

      c.define_tag 'translation' do |tag|
        tag.globals.translations[tag.attr['key']]
      end

      blog_path = obtain_blog_path

      blog = current_skin.cached_blog_with_path(blog_path)

      blog_page = blog.cached_blog_page_with_slug(blog_page_slug) rescue nil

      ConverlyHelper::BlogHelpers::AuthorTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::AuthorPageTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::BlogTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::BlogTagPageTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::BlogTagTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::BlogContentTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::BlogPageTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::BlogListTag.new(current_skin, blog_path, params, c)
      ConverlyHelper::BlogHelpers::BlogPageListTag.new(current_skin, blog_path, params, c)

      # Blog Content List
      c.define_tag 'blog_content_list' do |tag|
        fetch_cached_on_controller([], :blog_content_list) do
          content = []

          # Specify the content number limit to show
          limit_size = tag['limit'] || 10

          # Order the content list - most recent one on top
          recent = tag['recent'] == 'true' || true

          # Specify the page slug to query
          slug = tag['slug']

          # Pagination
          use_pagination = tag['pagination'] || false
          custom_pagination = tag['pagination_container_class'].present?

          blog_contents = []

          # Query blog content based on search keywords
          search_keyword = params[:search]
          if blog.present? && search_keyword.present?
            blog_contents = BlogContent.like(search_keyword)
              .joins(:blogs)
              .listable
              .with_blogs([blog])
              .published
          end

          # Query blog contents based on specific page
          if blog.present? && blog_contents.blank?
            blog_contents = BlogContent.with_slug(slug)
              .joins(:blogs)
              .listable
              .with_blogs([blog])
              .published
          end

          # Query blog contents from either:
          #   - blog page (identified by the slug)
          #   - author information
          #   - blog tag information
          if blog_contents.blank? && blog_page.present?
            blog_contents = BlogContent.joins(:blog_pages)
              .with_blog_pages([blog_page])
              .listable
              .published
          elsif blog_contents.blank? && params[:author_type].present? && params[:author_id].present?
            blog_contents = BlogContent.joins(:blogs)
              .with_blogs([blog])
              .where(
                author_type: params[:author_type],
                author_id: params[:author_id],
              )
              .listable
              .published
          elsif blog_contents.blank? && params[:tag].present?
            blog_tag = AffiliateTag.find(params[:tag]) rescue nil

            if blog_tag.present?
              blog_contents = BlogContent.with_blogs([blog])
                .joins(:blogs)
                .tag_joins
                .listable
                .published
                .with_tags([blog_tag])
            end
          end

          # Query blog contents from all published content
          if blog_contents.blank? && blog_page_slug.blank? && blog_page.blank? &&
             params[:author_type].blank? && params[:author_id].blank? && params[:tag].blank?
            blog_contents = BlogContent.with_blogs([blog])
              .joins(:blogs)
              .listable
              .published
          end

          if blog_contents.present?

            ##
            # Apply limit to the contents being returned
            blog_contents = blog_contents.limit(limit_size) if limit_size.present?

            ##
            # Apply recent order
            blog_contents = blog_contents.recent if recent.present?

            ##
            # Handle pagination
            current_page = params[:page] || 1
            per_page = tag['per_page'] || 10
            if use_pagination
              blog_contents = blog_contents.paginate(:page => current_page, :per_page => per_page)
            end

            ##
            # Prepare and render all blog contents to content
            blog_contents.each do |bc|
              tag.locals.blog_content = bc
              content << tag.expand
            end

            ##
            # Add pagination HTML content
            if use_pagination
              if custom_pagination
                custom_paginate_renderer = ConverlyHelper::BlogHelpers::PaginateRenderer.new
                custom_paginate_renderer.pagination_container_class = tag['pagination_container_class']
                custom_paginate_renderer.pagination_previous_page = tag['pagination_previous_page']
                custom_paginate_renderer.pagination_next_page = tag['pagination_next_page']
                custom_paginate_renderer.pagination_page_number = tag['pagination_page_number']
                custom_paginate_renderer.pagination_current_page_number = tag['pagination_current_page_number']
                content << view_context.will_paginate(blog_contents, renderer: custom_paginate_renderer)
              else
                content << view_context.will_paginate(blog_contents) rescue nil
              end
            end
          end

          content.join
        end # End cache
      end
    end

    @context
  end

  def obtain_blog_path
    to_return = []
    param_splits = []
    if params[:path].present?
      param_splits = params[:path].split('/')
    end

    # TODO: find better way to handle localization
    # than this
    if ['en-us', 'zh-tw'].include?(param_splits.first)
      to_return << param_splits[0]
      to_return << param_splits[1]
    else
      to_return << param_splits[0]
    end
    to_return.join('/')
  end

  def current_user
    nil
  end

  def blog_page_slug
    params[:page_slug] rescue nil
  end

  def current_skin
    @current_skin ||= SkinMap.with_hostname(request.host).first
  end
end
