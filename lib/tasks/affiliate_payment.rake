namespace :wl do
  namespace :affiliate_payments do
    task touch: :environment do
      AffiliatePayment.all.each do |affiliate_payment|
        print "Touch AffiliatePayment ID: #{affiliate_payment.id}..."
        puts affiliate_payment.touch
      end
      puts 'DONE!'
    end

    task save: :environment do
      AffiliatePayment.all.each do |affiliate_payment|
        print "Save AffiliatePayment ID: #{affiliate_payment.id}..."
        puts affiliate_payment.save
      end
      puts 'DONE!'
    end

    task update_commission: :environment do
      file_path = "#{Rails.root}/data/fix-payment-#{Rails.env}-2019-02-18.csv"

      CSV.foreach(
        file_path, {
          headers: true,
          skip_blanks: true,
          header_converters: :symbol,
        }
      ).each do |row|
        payment = AffiliatePayment.where(paid_at: '2019-03-03 16:00:00')
          .where(affiliate_id: row[:affiliate_id])

        payment = payment.last rescue nil

        next unless payment.present?

        new_amount = row[:affiliate_amount].to_f.round
        print "Updating payment for affiliate id: #{payment.affiliate_id} from #{payment.affiliate_amount} to #{new_amount}..."
        payment.update(
          affiliate_amount: new_amount,
        )
        puts 'DONE'
      end
    end

    task fix_duplicate_wire_fees: :environment do
      results = PaymentFee
        .select('affiliate_payment_id, count(*) AS counter')
        .where(label: 'Wire Fees')
        .group('affiliate_payment_id')

      puts "TOTAL RECORDS: #{results.length}"
      filtered = results.select { |x| x.counter > 1 }
      puts "TOTAL TO PROCESS: #{filtered.length}"
      filtered.each do |fee|
        payment = fee.affiliate_payment
        next unless payment.present?

        print "  PROCESSING PAYMENT ID: #{payment.id} "
        fees = payment.payment_fees.where(label: 'Wire Fees').order('id DESC')
        print " WIRE FEE COUNT: #{fees.length}..."
        fees[0, fees.length - 1].each do |fee|
          fee.destroy
        end
        puts 'DONE'
      end
    end

    task fix_duplicate_tax_fees: :environment do
      results = PaymentFee
        .select('affiliate_payment_id, count(*) AS counter')
        .where(label: 'Tax')
        .group('affiliate_payment_id')

      puts "TOTAL RECORDS: #{results.length}"
      filtered = results.select { |x| x.counter > 1 }
      puts "TOTAL TO PROCESS: #{filtered.length}"
      filtered.each do |fee|
        payment = fee.affiliate_payment
        next unless payment.present?

        print "  PROCESSING PAYMENT ID: #{payment.id} "
        fees = payment.payment_fees.where(label: 'Tax').order('id DESC')
        print " TAX FEE COUNT: #{fees.length}..."
        fees[0, fees.length - 1].each do |fee|
          fee.destroy
        end
        puts 'DONE'
      end
    end

    task migrate_dates: :environment do
      AffiliatePayment.where(start_date: nil, end_date: nil).find_each do |payment|
        start_date = TimeZone.platform.from_utc(payment.period_start_at).to_date if payment.period_start_at.present?
        end_date = TimeZone.platform.from_utc(payment.period_end_at).to_date if payment.period_end_at.present?
        paid_date = TimeZone.platform.from_utc(payment.paid_at).to_date if payment.paid_at.present?

        payment.update_columns(start_date: start_date, end_date: end_date, paid_date: paid_date)
      end
    end
  end
end
