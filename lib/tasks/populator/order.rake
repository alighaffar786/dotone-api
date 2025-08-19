require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with orders'
    task orders: :environment do
      RakeWl.when_populator_can_run do
        sample_data_count = RakeWl.ask_data_size

        [Order].each do |klass|
          klass.delete_all
        end

        Order.populate sample_data_count.to_i do |order|
          stat = AffiliateStat.all.sample
          offer = stat.offer
          affiliate = stat.affiliate
          step = offer.conversion_steps.sample

          specs = []
          specs << [' STAT: ', stat.id] if stat.present?
          specs << [' OFFER: ', offer.id] if offer.present?
          specs << [' AFFILIATE: ', affiliate.id] if affiliate.present?
          specs << [' STEP: ', step.id] if step.present?

          print "Inserting #{specs.join(' ')}"

          order.offer_id = offer.id
          order.offer_variant_id = offer.default_offer_variant.id
          order.affiliate_id = affiliate.id
          order.total = rand(10..10_008)
          if step.present? && step.true_conv_type == ConversionStep::CONV_TYPE_CPS
            order.order_number = "ORDER-#{rand(1001..10_999)}"
            order.affiliate_share = step.affiliate_share
            order.true_share = step.true_share
            order.affiliate_pay = (order.total * step.affiliate_share).to_f / 100
            order.true_pay = (order.total * step.true_share).to_f / 100
          else
            order.affiliate_pay = step.affiliate_pay rescue stat.affiliate_pay
            order.true_pay = step.true_pay rescue stat.true_pay
          end
          order.status = Order.statuses.sample
          order.recorded_at = stat.recorded_at
          order.converted_at = stat.recorded_at + rand(1..5).days
          order.affiliate_stat_id = stat.id

          if step.present?
            order.step_name = step.name
            order.step_label = step.label
            order.true_conv_type = step.true_conv_type
            order.affiliate_conv_type = step.affiliate_conv_type
            order.has_clicks = 1
          end

          puts '... DONE'
        end

        puts '=== Generating Copy Stats ==='
        Order.all.each do |order|
          print "Copy Stat for Order ID: #{order.id}..."
          order.save
          puts 'DONE'
        end
      end
    end
  end
end
