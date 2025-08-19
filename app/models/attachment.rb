class Attachment < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include LocalTimeZone
  include Owned
  include PurgeableFile

  DOCUMENT_TYPES = ['Front of ID', 'Back of ID', 'Bank Booklet', 'Tax Form', 'Valid ID']

  # TODO:
  # belongs_to :uploader, polymorphic: true, inverse_of: :attachments, touch: true

  validates :link, presence: true

  define_constant_methods DOCUMENT_TYPES, :name, prefix: :document_type
  set_local_time_attributes :created_at
  set_purgeable_file_attributes :link

  before_save :decide_legacy, if: :legacy?

  scope :documents, -> { where(name: document_type_names )}

  def link_url
    return if link.blank?

    S3_PRIVATE_BUCKET.object(object_key).presigned_url(:get)
  end

  def object_key
    if legacy? && link.present?
      "#{Rails.env}/attachment/#{id}/#{link}"
    else
      link
    end
  end

  # TODO: fix polymorphic
  def uploader=(user)
    self.uploader_id = user.id
    self.uploader_type = user.class.name.underscore
  end

  private

  def decide_legacy
    self.legacy = false if link_changed?
  end
end
