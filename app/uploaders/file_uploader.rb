class FileUploader < BaseUploader
  after :store, :set_cdn_url

  private

  def set_cdn_url(_)
    model.update(cdn_url: try(:url)) if model.class.column_names.include?('cdn_url')
  end
end
