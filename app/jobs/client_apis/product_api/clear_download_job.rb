class ClientApis::ProductApi::ClearDownloadJob < MaintenanceJob
  def perform
    FileUtils.rm_rf(DotOne::ApiClient::ProductApi::BaseClient.download_path)
  end
end
