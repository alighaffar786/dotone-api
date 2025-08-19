class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :fog

  def store_dir
    if model.new_record? || (model[mounted_as] && (new_file_exists? || legacy_file_empty?))
      new_store_dir
    else
      legacy_store_dir
    end
  end

  def new_store_dir
    "#{Rails.env}/dotone/#{model.class.to_s.underscore}/#{model.id}"
  end

  def legacy_store_dir
    site_name = model.class.connection.current_database
    "#{Rails.env}/#{site_name}/#{model.class.name.underscore}/#{model.id}"
  end

  def new_file_exists?
    path = File.join(new_store_dir, model[mounted_as])
    storage.connection.head_object(fog_directory, path).status == 200
  rescue Excon::Error::NotFound
    false
  end

  def legacy_file_empty?
    path = File.join(legacy_store_dir, model[mounted_as])
    storage.connection.head_object(fog_directory, path).status != 200
  rescue Excon::Error::NotFound
    true
  end
end
