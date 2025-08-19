class AdBannerUploader < ImageUploader
  def store_dir
    "#{Rails.env}/#{model.class.to_s.underscore}/user-#{model.user_id}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fill: [100, 50]
  end
end
