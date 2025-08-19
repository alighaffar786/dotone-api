class ScriptUploader < BaseUploader
  def filename
    encrypted = DotOne::Utils::Encryptor.hexdigest(model.id.to_s)
    "#{encrypted}.js" if original_filename
  end
end
