class AvatarUploader < ImageUploader
  def store_dir
    "#{super}/avatar"
  end

  def filename
    SecureRandom.uuid
  end
end
