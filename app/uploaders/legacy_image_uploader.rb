class LegacyImageUploader < ImageUploader
  def store_dir
    legacy_store_dir
  end
end
