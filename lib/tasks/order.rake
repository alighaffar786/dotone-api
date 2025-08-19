namespace :wl do
  namespace :orders do
    task save: :environment do
      start_at, end_at = RakeWl.ask_date_range
      time_zone = TimeZone.platform
      orders = Order.between(start_at, end_at, time_zone, :created_at)
      puts "Total Orders: #{orders.length}"
      RakeWl.ask_continue
      orders.each do |order|
        print "Saving Order ID: #{order.id}..."
        puts order.save
      end
      puts 'DONE!'
    end

    task remove_dups_using_recorded_at: :environment do
      start_at, end_at = RakeWl.ask_date_range

      orders = Order.where(
        'recorded_at >= ? AND recorded_at <= ?',
        "#{start_at} 00:00:00",
        "#{end_at} 23:59:59",
      )

      order_numbers = orders.map(&:order_number).uniq

      puts "Total Orders: #{order_numbers.length}"
      RakeWl.ask_continue

      order_numbers.each do |order_number|
        puts "Checking Order Number: #{order_number}..."
        orders = Order.where(order_number: order_number).order('id DESC')
        oo_hash = orders.group_by { |x| x.offer_id }
        oo_hash.each_pair do |offer_id, oo|
          puts "  Offer ID #{offer_id}   Length: #{oo.length}"
          next unless oo.length > 1

          oo[0, oo.length - 1].each do |x|
            print "    Removing Order #{x.id}..."
            x.destroy
            puts ' DONE'
          end
        end
      end
    end

    task remove_dups_using_order_numbers: :environment do
      order_numbers = RakeWl.ask_for('Order Numbers')
      order_numbers = order_numbers.split(',')
      order_numbers.each do |order_number|
        puts "Checking Order Number: #{order_number}..."
        orders = Order.where(order_number: order_number).order('id DESC')
        oo_hash = orders.group_by { |x| x.offer_id }
        oo_hash.each_pair do |offer_id, oo|
          puts "  Offer ID #{offer_id}   Length: #{oo.length}"
          next unless oo.length > 1

          oo[0, oo.length - 1].each do |x|
            print "    Removing Order #{x.id}..."
            x.destroy
            puts ' DONE'
          end
        end
      end
    end
  end
end
