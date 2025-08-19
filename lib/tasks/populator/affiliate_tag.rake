require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy owner has tags'
    task :owner_has_tags, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Owner Has Tags'

        puts '  Destroy old data'
        [OwnerHasTag].each do |klass|
          klass.delete_all
        end

        offers = Offer.all

        puts '  Generate tags for Top Network Offers'

        # Populate Top Network Offers
        AffiliateTag.top_network_offers.each do |affiliate_tag|
          chosen_offers = offers.sample(16)
          OwnerHasTag.populate 16 do |tag|
            tag.owner_id = chosen_offers.rotate!.first.id
            tag.owner_type = 'Offer'
            tag.affiliate_tag_id = affiliate_tag.id
          end
        end

        # Populate New Offers & Top Offers
        puts '  Generate data for New & Top Offers'
        AffiliateTag.for_offers.each do |affiliate_tag|
          index = 0
          chosen_offers = offers.sample(10)
          OwnerHasTag.populate 10 do |tag|
            tag.owner_id = chosen_offers.rotate!.first.id
            tag.owner_type = 'Offer'
            tag.affiliate_tag_id = affiliate_tag.id
            tag.display_order = index
            index += 1
          end
        end

        # Populate internal Marketing Offer Slots
        puts '  Generate data for Marketing Offer Slots'
        AffiliateTag.for_offer_slots.each do |affiliate_tag|
          index = 0
          chosen_offers = offers.sample(10)
          OwnerHasTag.populate 5 do |tag|
            tag.owner_id = chosen_offers.rotate!.first.id
            tag.owner_type = 'Offer'
            tag.affiliate_tag_id = affiliate_tag.id
            tag.display_order = index
            index += 1
          end
        end

        # Populate media restriction for Offers
        puts '  Generate media restrictions for offers'
        AffiliateTag.where(tag_type: AffiliateTag::TAG_TYPES.media_restriction).each do |affiliate_tag|
          chosen_offers = offers.sample(10)
          OwnerHasTag.populate 3 do |tag|
            tag.owner_id = chosen_offers.rotate!.first.id
            tag.owner_type = 'Offer'
            tag.affiliate_tag_id = affiliate_tag.id
          end
        end

        affiliates = Affiliate.all.to_a

        # Populate media categories for affiliates
        puts '  Generate media categories for affiliates'
        media_categories = AffiliateTag.children_media_categories.to_a

        OwnerHasTag.populate(affiliates.length) do |tag|
          tag.owner_id = affiliates.rotate!.first
          tag.owner_type = 'Affiliate'
          tag.affiliate_tag_id = media_categories.rotate!.first
        end
      end
    end
  end
end
