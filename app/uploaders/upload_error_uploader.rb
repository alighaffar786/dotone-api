class UploadErrorUploader < BaseUploader
  def store_dir
    "#{Rails.env}/dotone/upload_errors/#{model.id}"
  end

  def filename
    "#{SecureRandom.uuid}.txt"
  end
end
