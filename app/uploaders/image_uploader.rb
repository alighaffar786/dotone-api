class ImageUploader < BaseUploader
  def extension_white_list
    ['jpg', 'jpeg', 'gif', 'png']
  end

  def geometry
    @geometry ||= get_geometry
  end

  def get_geometry
    return unless @file

    img = ::Magick::Image.read(@file.file).first
    geometry = { width: img.columns, height: img.rows }
  end
end
