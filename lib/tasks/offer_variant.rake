require 'rake_wl'

namespace :wl do
  namespace :offer_variants do
    task save: :environment do
      entities = OfferVariant.all
      puts "Total Offer Variants: #{entities.length}"
      RakeWl.ask_continue
      entities.each do |entity|
        print "Saving Offer Variant ID: #{entity.id}..."
        result = entity.save
        puts result == false ? entity.errors : 'DONE'
      end
    end
  end
end
