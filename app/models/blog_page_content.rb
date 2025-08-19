class BlogPageContent < DatabaseRecords::PrimaryRecord
  belongs_to :blog_page, inverse_of: :blog_page_contents, touch: true
  belongs_to :blog_content, inverse_of: :blog_page_contents, touch: true

  validates :blog_page, :blog_content, presence: true
end
