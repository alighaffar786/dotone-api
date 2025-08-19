class ImageAssetUploader < ImageUploader
  def filename
    DotOne::Utils.generate_token
  end
end
