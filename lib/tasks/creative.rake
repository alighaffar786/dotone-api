require 'rake_wl'

namespace :wl do
  namespace :creatives do
    namespace :images do
      desc 'Cache delivery for active image creatives'
      task cache_delivery: :environment do
        min_id = RakeWl.ask_min_id
        image_creatives = ImageCreative.active.where('id >= ?', min_id).to_a
        puts "Total Active Image Creatives: #{image_creatives.length}"
        RakeWl.ask_continue
        image_creatives.each do |img|
          print "Cache Delivery Image Creative ID: #{img.id}..."
          result = img.cache_for_delivery
          puts result.status
        end
        puts 'DONE!'
      end
    end
  end
end
