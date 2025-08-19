require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with postbacks'
    task :postbacks, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        # db connect & initialization
        is_silent = options[:silent] == true

        puts 'Generate Ad Slots'

        # cleanup
        puts '  Destroy old data'
        [Postback].each do |klass|
          klass.delete_all
        end

        affiliate_stats = AffiliateStat.where(conversions: 1).limit(1000)

        puts '  Generate data'
        Postback.populate 500 do |postback|
          postback.postback_type = Postback::POSTBACK_TYPE_IN
          postback.raw_response = 'OK'
          postback.raw_request = "http://test.com/postback?tid=#{rand(10_000)}"
          postback.affiliate_stat_id = affiliate_stats.sample.id
        end

        Postback.populate 500 do |postback|
          postback.postback_type = Postback::POSTBACK_TYPE_OUT
          postback.raw_response = 'OK'
          postback.raw_request = "http://affiliate_tracking.com/postback?tid=#{rand(10_000)}"
          postback.affiliate_stat_id = affiliate_stats.sample.id
        end
      end
    end
  end
end
