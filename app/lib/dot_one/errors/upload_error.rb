module DotOne::Errors
  class UploadError < BaseError
    def initialize(upload, details = '', options = {})
      super(DotOne::I18n.err('upload.base'))
      @payload = { id: upload.id, file_url: upload.cdn_url }
      @details = DotOne::I18n.err(details, **options)
    end
  end
end
