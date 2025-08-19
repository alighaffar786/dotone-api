require 'stringex_lite'

class BlogContent < DatabaseRecords::PrimaryRecord
  include AffiliateTaggable
  include ConstantProcessor
  include Scopeable
  include BlogContentHelpers::EsSearch

  STATUSES = ['Draft', 'Published', 'Hide'].freeze

  belongs_to :blog_image, inverse_of: :blog_content
  belongs_to :author, polymorphic: true, inverse_of: :blog_contents

  has_many :blog_page_contents, inverse_of: :blog_content, dependent: :destroy
  has_many :blog_pages, through: :blog_page_contents
  has_many :blogs, through: :blog_pages
  has_many :blog_tags, through: :owner_has_tags

  has_one :main_page_content, class_name: 'BlogPageContent'
  has_one :main_page, through: :main_page_content, source: :blog_page
  has_one :main_blog, through: :main_page, source: :blog

  validates :title, :html, :status, :author_id, presence: true
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  # Slug makes pretty url and prevent user from typing id to find blog content
  before_validation :set_defaults

  define_constant_methods STATUSES, :status

  default_scope { where(author_type: 'AffiliateUser') }

  scope_by_status

  scope :listable, -> { joins(:blog_pages).merge(BlogPage.listable) }
  scope :home_page, -> { joins(:blog_pages).merge(BlogPage.home_page) }
  scope :index_page, -> { where(title: BlogPage.index_page_name) }

  scope :like, -> (*args) {
    if args[0].present?
      where(id: args[0]).or(where('blog_contents.title LIKE :q OR blog_contents.html LIKE :q', q: "%#{args[0]}%"))
    end
  }

  scope :with_blog_pages, -> (*args) {
    values = args.flatten.map { |x| x.id rescue x }
    joins(:blog_pages).where(blog_pages: { id: values }) if values.present?
  }

  scope :with_blogs, -> (*args) {
    values = args.flatten.map { |x| x.id rescue x }
    joins(:blogs).where(blogs: { id: values }) if values.present?
  }

  scope :with_slug, -> (arg) { where(slug: arg) }

  scope :recent, -> { where('posted_at <= NOW()').order(posted_at: :desc, id: :desc) }

  scope :like, -> (*args) {
    if args.present? && args[0].present?
      where('LOWER(blog_contents.title) LIKE :q OR LOWER(blog_contents.short_description) LIKE :q OR LOWER(blog_contents.html) LIKE :q', q: "%#{args[0].downcase}%")
    end
  }

  def tag_names
    blog_tags.map(&:name)
  end

  def tag_names=(values)
    values = values.map(&:strip).map(&:titleize)

    self.blog_tags = values.map do |value|
      AffiliateTag.blog_tags.find_or_initialize_by(name: value)
    end
  end

  def id_with_name
    [id, title.capitalize].join(' - ')
  end

  def image_url
    blog_image&.cdn_url
  end

  def page_name
    main_page.name
  end

  def posted_year
    posted_at&.strftime('%Y')
  end

  def posted_month_name
    posted_at&.strftime('%B')
  end

  def posted_month_name_short
    posted_at&.strftime('%b')
  end

  def posted_month_number
    posted_at&.strftime('%m')
  end

  def posted_date_number
    posted_at&.strftime('%d')
  end

  def posted_date
    posted_at&.strftime('%B %d, %Y')
  end

  def page_link
    "p-#{main_page.slug}.html"
  end

  def page_path
    ['/', main_blog.path, '/page/', page_link].join
  end

  def author_name
    author&.full_name || 'Admin'
  end

  def author_avatar_url
    return unless author.present? && author.respond_to?(:avatar_cdn_url)

    author.avatar_cdn_url
  end

  def content_link
    "s-#{id}-#{slug}.html"
  end

  def content_path
    ['/', main_blog.path, '/post/', content_link].join
  end

  def related_contents(size = 5)
    main_page.blog_contents.where.not(id: id).published.sample(size.to_i)
  end

  private

  def set_defaults
    self.slug = title.to_url if slug.blank?
    self.status ||= BlogContent.status_draft
  end
end
