namespace :wl do
  namespace :offers do
    task touch: :environment do
      Offer.all.each do |record|
        print "Touch Offer ID: #{record.id_with_name}..."
        puts record.touch
      end
      puts 'DONE!'
    end

    task save: :environment do
      Offer.all.each do |record|
        print "Saving Offer ID: #{record.id_with_name}..."
        puts record.save
      end
      puts 'DONE!'
    end

    task touch_suspended_at: :environment do
      OfferVariant.where(status: 'Suspended').each do |variant|
        trace = variant.traces.where('notes LIKE "%Status: % => Suspended%"').last
        offer = variant.offer
        puts "Offer ID: #{offer.id} suspended_at: #{offer.suspended_at}"
        if variant.suspended_at.blank?
          puts "  Offer ID: #{variant.offer.id} suspended_at updated"
          variant.offer.update_column(:suspended_at, trace.created_at)
        else
          puts "  Offer ID: #{variant.offer.id} failed to update suspended_at"
        end
      end

      puts 'DONE!'
    end
  end
end
