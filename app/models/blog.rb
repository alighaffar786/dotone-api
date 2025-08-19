class Blog < DatabaseRecords::PrimaryRecord
  include ModelCacheable

  belongs_to :skin_map, inverse_of: :blogs

  has_many :blog_pages, inverse_of: :blog, dependent: :destroy
  has_many :blog_contents, through: :blog_pages
  has_many :blog_tags, through: :blog_contents
  has_many :authors, through: :blog_contents, source_type: 'AffiliateUser'

  has_many :published_blog_contents, through: :blog_pages
  has_many :authors_with_published_contents, -> { active }, through: :published_blog_contents, source: :author, source_type: 'AffiliateUser'

  validates :skin_map_id, :path, presence: true
  validates :name, presence: true, uniqueness: true

  before_save :cleaup_path

  set_instance_cache_methods :blog_page_with_slug, :blog_contents, :ordered_blog_tags

  scope :like, -> (*args) {
    where(id: args[0]).or(where('blogs.name LIKE ?', "%#{args[0]}%")) if args[0].present?
  }

  scope :with_path, -> (path) {
    term = path.split('/').compact_blank[0..1].join('/')
    where('path LIKE ?', "#{term}")
  }

  def id_with_name
    "#{id}- #{name}"
  end

  # List out blog pages with available published
  # contents. Useful to display page list
  # on blog pages where pages with unavailable contents
  # will be hidden
  def blog_pages_with_published_contents
    blog_pages.listable.joins(:published_blog_contents).distinct.order(name: :asc)
  end

  def ordered_blog_tags(limit = 15)
    blog_tags.order(updated_at: :desc).limit(limit)
  end

  def blog_page_with_slug(slug)
    blog_pages.with_slug(slug).last
  end

  private

  def cleaup_path
    self.path = path.gsub(%r{^/+|/+$}, '')
  end
end
