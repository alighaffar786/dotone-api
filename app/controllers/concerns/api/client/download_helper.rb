module Api::Client::DownloadHelper
  def build_download(collection, columns = [], header_options = {})
    model = collection.klass

    Download.new(
      file_type: model.download_file_type,
      name: model.download_name,
      notes: model.generate_download_notes(params),
      headers: model.generate_download_headers(columns, **header_options.merge(user: current_user)),
      exec_sql: collection.to_sql,
      owner: current_user,
      downloaded_by: current_user&.name_with_role,
      download_format: current_download_format,
    )
  end

  def start_download_job(download, formatters: nil)
    download.queue_generate(
      locale: current_locale,
      currency_code: current_currency_code,
      time_zone: current_time_zone,
      formatters: formatters,
    )
  end
end
