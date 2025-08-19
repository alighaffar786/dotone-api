class PopupFeed < DatabaseRecords::PrimaryRecord
  include DynamicTranslatable
  include LocalDateZone
  include PurgeableFile

  validates :title, :button_label, :start_date, :end_date, :cdn_url, presence: true

  set_dynamic_translatable_attributes(title: :plain, button_label: :plain)
  set_local_date_attributes :start_date, :end_date
  set_purgeable_file_attributes :cdn_url

  scope :active, -> { where('start_date <= ? AND end_date >= ? AND published = TRUE', Time.current, Time.current) }

  def active?
    start_date <= Time.current && end_date >= Time.current && published?
  end
end
