require 'csv'

namespace :wl do
  namespace :missing_order do
    task update_pending_inquiries: :environment do
      network_ids = [293, 615, 140, 169, 8464, 644, 557, 27633, 688, 295, 313, 104]

      def reject_missing_order(missing_order, csv)
        puts "updating #{missing_order.id}"
        row = [missing_order.id, missing_order.status_summary, missing_order.status_reason]
        missing_order.skip_notification = true
        missing_order.status = MissingOrder.status_rejected
        missing_order.status_summary = MissingOrder.status_summary_source_invalid
        missing_order.status_reason = DotOne::I18n.predefined_t('missing_order.status_reason.Source Invalid')
        missing_order.save!

        row.push(missing_order.valid?)

        csv << row
      end

      puts 'start: no postback'
      CSV.open('tmp/inquiry_no_postback.csv', 'w') do |csv|
        csv << ['id', 'status_summary', 'status_reason', 'is_valid']

        MissingOrder
          .joins(:offer)
          .pending
          .no_postback
          .where(offers: { network_id: network_ids })
          .between(nil, '2024-05-31', :created_at, any: true)
          .each do |missing_order|
            reject_missing_order(missing_order, csv)
          end
      end

      puts 'start: unconfirmed'
      CSV.open('tmp/inquiry_unconfirmed.csv', 'w') do |csv|
        csv << ['id', 'status_summary', 'status_reason', 'is_valid']

        MissingOrder
          .joins(:offer)
          .pending
          .unconfirmed
          .where(offers: { network_id: network_ids })
          .between(nil, '2023-08-31', :created_at, any: true)
          .each do |missing_order|
            reject_missing_order(missing_order, csv)
          end
      end
    end

    task update_pending_no_postback: :environment do
      offer_ids = [
        2921, 2525, 2427, 2169, 2328, 2170, 1661, 2115, 3996, 1605, 3506, 1150, 4389,
        4978, 2884, 1809, 5183, 3499, 3383, 4763, 4225, 4723, 3621, 1660, 1399
      ]

      CSV.open("tmp/inquiry_no_postback_#{Time.now.to_i}.csv", 'w') do |csv|
        csv << ['id', 'status_summary', 'status_reason', 'is_valid']

        MissingOrder
          .pending
          .no_postback
          .where(offer_id: offer_ids)
          .between(nil, '2024-05-31', :created_at, any: true)
          .find_each do |missing_order|
            puts "updating #{missing_order.id}"
            row = [missing_order.id, missing_order.status_summary, missing_order.status_reason]

            missing_order.skip_notification = true
            missing_order.status = MissingOrder.status_rejected
            missing_order.status_summary = MissingOrder.status_summary_source_invalid
            missing_order.status_reason = DotOne::I18n.predefined_t('missing_order.status_reason.Source Invalid')
            missing_order.save!

            row.push(missing_order.valid?)

            csv << row
          end
      end
    end
  end
end
