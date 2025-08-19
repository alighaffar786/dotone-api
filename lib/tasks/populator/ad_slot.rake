require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy ad_slots'
    task :ad_slots, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}
        puts 'Generate Ad Slots'

        puts '  Destroy old data'
        [AdSlot, AdSlotCategoryGroup].each do |klass|
          klass.delete_all
        end

        puts '  Generate data'
        AdSlot.populate 10 do |as|
          as.affiliate_id = Affiliate.all.map(&:id).sample rescue 1
          as.width = [300, 200, 500].sample
          as.height = [100, 1000, 500].sample
          as.display_format = AdSlot.display_formats.sample

          AdSlotCategoryGroup.populate 2 do |acg|
            acg.ad_slot_id = as.id
            acg.category_group_id = CategoryGroup.all.sample
          end
        end

        AdSlot.find_each do |as|
          ConverlyHelper::AdSlotHelpers::DeliveryAgent.refresh_inventories(as)
        end
      end
    end
  end
end
