namespace :wl do
  namespace :affiliate_offers do
    desc 'Remove any duplicates'
    task remove_dups: :environment do
      sql = <<-SQL
        SELECT b.*
        FROM
            (SELECT
              offer_id, affiliate_id, count(*) as counter
            FROM
                affiliate_offers
            GROUP BY offer_id , affiliate_id) b
        WHERE
            b.counter > 1;
      SQL

      results = AffiliateOffer.connection.select_all(sql)

      results.each do |result|
        entities = AffiliateOffer.where(
          offer_id: result['offer_id'],
          affiliate_id: result['affiliate_id'],
        )

        next unless entities.length > 1

        puts "Deleting: #{result}: "
        entities.shift
        entities.each do |x|
          print "  Affiliate Offer: #{x.id}..."
          x.destroy
          puts ' DELETED'
        end
      end
    end

    desc 'Assign split custom commissions'
    task split_custom_commissions: :environment do
      affiliates = RakeWl.ask_affiliates
      offers = RakeWl.ask_offers
      print 'Affiliate Split (ex: 0.80): '
      split = STDIN.gets.chomp

      raise 'Split is required' if split.blank?

      split = split.to_f

      affiliates.each do |affiliate|
        puts "Assigning commission for Affiliate #{affiliate.id}:"
        offers.each do |offer|
          puts "  For Offer #{offer.id}:"
          campaign = AffiliateOffer.best_match(affiliate, offer)
          if campaign.blank?
            puts '    CAMPAIGN NOT FOUND'
            next
          end

          conversion_points = offer.conversion_steps

          conversion_points.each do |conversion_point|
            puts "    For Conversion Point #{conversion_point.id} - #{conversion_point.name}:"
            custom_price = conversion_point.step_prices.where(affiliate_offer_id: campaign.id).first rescue nil
            custom_share = split * conversion_point.true_share rescue nil
            custom_amount = split * conversion_point.true_pay rescue nil

            updates = {
              custom_amount: custom_amount,
              custom_share: custom_share,
              affiliate_offer_id: campaign.id,
              conversion_step_id: conversion_point.id,
            }

            if custom_price.present?
              if custom_price.update(updates)
                puts "      Updating custom price #{custom_price.id}: DONE"
                campaign.update(is_custom_commission: true)
              else
                puts "      Updating custom price #{custom_price.id}: FAIL"
              end
            else
              step_price = StepPrice.new(updates)
              if step_price.save
                puts "      Creating new custom price #{step_price.id}: DONE"
                campaign.update(is_custom_commission: true)
              else
                puts "      Creating new custom price #{step_price.id}: FAIL"
              end
            end
          end
        end
      end
    end

    task save: :environment do
      AffiliateOffer.all.each do |affiliate_offer|
        print "Save Affiliate Offer ID: #{affiliate_offer.id}..."
        puts affiliate_offer.save
      end
      puts 'DONE!'
    end

    task touch: :environment do
      AffiliateOffer.find_in_batches(batch_size: 500) do |group|
        group.each do |affiliate_offer|
          print "Touch Affiliate Offer ID: #{affiliate_offer.id}..."
          puts affiliate_offer.touch
        end
      end
      puts 'DONE!'
    end
  end
end
