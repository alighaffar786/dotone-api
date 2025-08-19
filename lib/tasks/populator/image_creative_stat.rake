require 'faker'
require 'populator'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :image_creative_stats, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Image Creative Stats'

        puts '  Destroy old data'

        [ImageCreativeStat].each do |klass|
          klass.delete_all
        end

        image_creatives = ImageCreative.all.to_a
        dates = ((Date.today - 30.days)..(Date.today)).to_a

        puts '  Generate data for image creative stats'
        dates.each do |date|
          ImageCreativeStat.populate image_creatives.length do |stat|
            stat.image_creative_id = image_creatives.rotate!.first.id
            stat.ui_download_count = rand(1..50)
            stat.date = date.to_s
          end
        end
      end
    end
  end
end
