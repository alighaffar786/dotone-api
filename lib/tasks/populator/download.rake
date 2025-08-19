require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :downloads, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Downloads'

        puts '  Destroy old data'
        [Download].each do |klass|
          klass.delete_all
        end

        puts '  Prepare download files'
        files = [
          "#{RakeWl::IMAGE_BASE_PATH}/downloads/test-01.csv",
          "#{RakeWl::IMAGE_BASE_PATH}/downloads/test-02.csv",
          "#{RakeWl::IMAGE_BASE_PATH}/downloads/test-03.csv",
        ]

        # Generate for Advertisers
        puts '  Generate downloads data for networks'
        advertisers = Network.all.to_a
        Download.populate advertisers.length * 2 do |download|
          this_advertiser = advertisers.rotate!.first
          download.owner_type = 'Network'
          download.owner_id = this_advertiser.id
          download.downloaded_by = "#{this_advertiser.name} (Advertiser)"
          download.status = ['Ready', 'In Progress'].sample
          download.file_type = 'AffiliateStat'
          download.name = 'Transactions'
          download.notes = 'Test download'
        end

        # Generate for Affiliate
        puts '  Generate downloads data for affiliates'
        affiliates = Affiliate.all.to_a
        Download.populate affiliates.length * 2 do |download|
          this_affiliate = affiliates.rotate!.first
          download.owner_type = 'Affiliate'
          download.owner_id = this_affiliate.id
          download.downloaded_by = "#{this_affiliate.name} (Affiliate)"
          download.status = ['Ready', 'In Progress'].sample
          download.file_type = 'AffiliateStat'
          download.name = 'Transactions'
          download.notes = 'Test download'
        end

        Download.all.each do |download|
          file = files.sample
          download.file = File.open(file)
          download.save
        end

        Download.all.each do |download|
          download.save
        end
      end
    end
  end
end
