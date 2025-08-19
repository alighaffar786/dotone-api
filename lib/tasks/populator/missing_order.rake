require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy missing_orders'
    task :missing_orders, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Missing Orders'

        puts '  Destroy old data'
        [MissingOrder].each do |klass|
          klass.delete_all
        end

        affiliate_ids = Affiliate.all.map(&:id)
        offer_ids = NetworkOffer.all.map(&:id)
        currency_id = Currency.first
        order_ids = Order.all.map(&:id).shuffle

        MissingOrder.populate affiliate_ids.length * 3 do |missing_order|
          missing_order.affiliate_id = affiliate_ids.rotate!.first
          missing_order.offer_id = offer_ids.sample
          missing_order.question_type = MissingOrder.question_types.sample
          missing_order.order_number = "ORDER-#{rand(1001..10_999)}"
          missing_order.order_time = Time.now - rand(1..10).days
          missing_order.order_total = (rand(1..1200))
          missing_order.payment_method = MissingOrder.payment_methods.sample
          missing_order.click_time = missing_order.order_time - (1 + 100).days
          missing_order.device = MissingOrder.devices.sample
          missing_order.notes = Faker::Lorem.words(number: 5).join(' ')
          missing_order.status = MissingOrder.statuses.sample
          missing_order.currency_id = currency_id
          missing_order.true_pay = Faker::Number.decimal(l_digits: 3, r_digits: 2)
          missing_order.status_summary = begin
            case missing_order.status
            when MissingOrder.status_approved
              MissingOrder.approval_summaries.sample
            when MissingOrder.status_rejected_by_admin || MissingOrder.status_rejected_by_advertiser
              MissingOrder.rejection_summaries.sample
            end
          end

          missing_order.status_reason = Faker::Lorem.words(number: 10).join(' ')

          missing_order.order_id = order_ids.sample if [MissingOrder.status_approved, MissingOrder.status_completed].include?(missing_order.status)

          if [MissingOrder.status_approved, MissingOrder.status_rejected_by_admin, MissingOrder.status_rejected_by_advertiser].include?(missing_order.status)
            missing_order.confirming_at = missing_order.order_time + rand(10).hours
          end
        end
      end
    end
  end
end
