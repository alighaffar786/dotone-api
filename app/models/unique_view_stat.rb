class UniqueViewStat < DatabaseRecords::PrimaryRecord
  include DateRangeable
  include Relations::AffiliateAssociated

  belongs_to :site_info, inverse_of: :unique_view_stats

  validates :site_info_id, uniqueness: { scope: [:date, :batch] }, presence: true
  validates :date, :count, presence: true

  before_save :adjust_values

  scope :last_30_days, -> { where(date: 30.days.ago..Time.now).order(:date) }

  private

  def adjust_values
    self.affiliate_id ||= site_info.affiliate.id
  end
end
