namespace :util do
  namespace :csv do
    desc 'Deal with Involve Asia different order format on CSV file'
    task convert_ia_csv: :environment do
      require 'csv'

      source_csv_file = "#{Rails.root}/data/involve-orders-20210312.csv"
      target_csv_file = "#{Rails.root}/data/involve-orders-20210312-converted.csv"
      not_exist_csv_file = "#{Rails.root}/data/involve-orders-20210312-not-exist.csv"

      currency_rate = Currency.rate('MYR', 'USD')

      CSV.open(target_csv_file, 'wb') do |target_row|
        target_row << ['order_number', 'order_total', 'true_pay', 'merchant']
        CSV.open(not_exist_csv_file, 'wb') do |not_exist_row|
          CSV.foreach(source_csv_file, headers: true, header_converters: :symbol) do |source_row|
            order_id_to_use = source_row[:order_id]
            existing_order = Order.where(order_number: order_id_to_use).first

            if existing_order.blank?
              order_id_to_use = source_row[:orderid_in_affiliateone]
              existing_order = Order.where(order_number: order_id_to_use).first
            end

            if existing_order.blank?
              not_exist_row << source_row.fields
              next
            end

            true_pay = currency_rate * source_row[:est_earning_myr].to_f
            order_total = currency_rate * source_row[:sale_amount_myr].to_f

            target_row << [order_id_to_use, order_total, true_pay, source_row[:merchant]]
          end
        end
      end
    end
  end
end
