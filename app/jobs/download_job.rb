# frozen_string_literal: true

class DownloadJob < ApplicationJob
  queue_as :download_csv

  def perform(download_id, options = {})
    catch_exception do
      @download = Download.find(download_id)
      @download.generate(options)
    rescue StandardError => e
      @download.update_column(:status, Download.status_error)
      raise e
    end
  end
end
