class Image < DatabaseRecords::PrimaryRecord
  include ConstantProcessor
  include PurgeableFile

  IMAGE_TYPES = ['Avatar', 'Brand Image', 'Brand Image Small', 'Brand Image Medium', 'Brand Image Large']

  belongs_to :owner, polymorphic: true, touch: true, autosave: true, validate: false

  mount_base64_uploader :asset, ImageAssetUploader

  define_constant_methods IMAGE_TYPES, :image_type
  set_purgeable_file_attributes :cdn_url

  amoeba do
    enable
  end

  def cdn_url
    self[:cdn_url].presence || asset&.url
  end
end
