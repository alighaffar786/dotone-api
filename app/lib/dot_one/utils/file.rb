class DotOne::Utils::File
  def self.create_dir(name)
    path = "#{Rails.root}/tmp/#{name}"
    delete_dir(path) if File.exist?(path)
    Dir.mkdir(path)
    path
  end

  def self.delete_dir(path)
    if File.directory?(path)
      FileUtils.rm_rf(Dir.glob("#{path}/*"))
      Dir.delete(path) rescue nil
    else
      File.delete(path) rescue nil
    end
  end

  def self.delete_file(path)
    File.delete(path)
  rescue StandardError
  end

  def self.generate_filename(name)
    "#{Rails.root}/tmp/#{name}"
  end

  def self.generate_temp_filename(ext)
    "#{Rails.root}/tmp/#{SecureRandom.uuid}.#{ext}"
  end
end
