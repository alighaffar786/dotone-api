require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :uploads, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Uploads'

        puts '  Destroy old data'
        [Upload].each do |klass|
          klass.delete_all
        end

        puts '  Prepare upload files'
        image_path = "#{RakeWl::CDN_BASE_PATH}/uploads"
        files = [
          "#{image_path}/test-01.csv",
          "#{image_path}/test-02.csv",
          "#{image_path}/test-03.csv",
        ]

        # Generate for Advertisers
        puts '  Generate data for uploads'
        advertisers = Network.all.to_a
        Upload.populate 50 do |upload|
          this_advertiser = advertisers.sample
          upload.owner_type = 'Network'
          upload.owner_id = this_advertiser.id
          upload.uploaded_by = "#{this_advertiser.name} (Advertiser)"
          upload.status = ['Ready', 'In Progress', 'Error', 'Warning'].sample
          upload.descriptions = 'Test upload'
          upload.error_details = 'Test error message' if upload.status == 'Error'
          file = files.sample
          upload.cdn_url = file
        end
      end
    end
  end
end
