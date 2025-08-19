class AdLinkJsUploader < BaseUploader
  def store_dir
    "#{Rails.env}/adlinks"
  end

  def filename
    encrypted = DotOne::Utils::Encryptor.hexdigest(model.id.to_s)
    "#{encrypted}.js" if original_filename
  end
end
