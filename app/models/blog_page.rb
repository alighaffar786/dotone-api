class BlogPage < DatabaseRecords::PrimaryRecord
  INDEX_PAGE_NAME = '[INDEX]'.freeze

  belongs_to :blog, inverse_of: :blog_pages

  has_many :blog_page_contents, inverse_of: :blog_page, dependent: :destroy
  has_many :blog_contents, through: :blog_page_contents
  has_many :authors, through: :blog_contents, source_type: 'AffiliateUser'

  has_many :published_blog_contents, -> { published }, through: :blog_page_contents, source: :blog_content

  validates :name, :blog_id, presence: true
  validates :name, :slug, uniqueness: { scope: :blog_id, case_sensitive: false }
  validates :slug, presence: true, unless: :index_page?

  before_validation :generate_slug

  scope :home_page, -> { where(name: INDEX_PAGE_NAME) }
  scope :listable, -> { where.not(name: INDEX_PAGE_NAME) }

  scope :like, -> (*args) {
    if args[0].present?
      where(id: args[0]).or(where('blog_pages.name LIKE ? ', "%#{args[0]}%"))
    end
  }

  scope :with_blogs, -> (*args) {
    joins(:blog).where(blogs: { id: args[0]}).or(where('blogs.name LIKE ? ', "%#{args[0]}%")) if args[0].present?
  }

  scope :with_slug, -> (*args) { where(slug: args[0]) if args[0].present? }

  def self.index_page_name
    INDEX_PAGE_NAME
  end

  def index_page?
    name == BlogPage.index_page_name
  end

  def id_with_name
    [id, name.capitalize].reject(&:blank?).join(' - ')
  end

  def content_link
    "p-#{slug}.html"
  end

  def page_path
    ['/', blog.path, '/page/', content_link].join
  end

  def content_count
    published_blog_contents.count
  end

  def blog_tags
    blog_contents.map(&:blog_tags).flatten.uniq
  end

  private

  def generate_slug
    self.slug ||= name.to_url
  end
end
