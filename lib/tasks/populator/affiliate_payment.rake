require 'populator'
require 'faker'
require 'rake_wl'

namespace :wl do
  namespace :pop do
    desc 'Populate database with dummy affiliate payments'
    task :affiliate_payments, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        [AffiliatePayment, PaymentFee].each do |klass|
          klass.delete_all
        end

        Affiliate.all.each do |affiliate|
          AffiliatePayment.populate 1 do |payment|
            paid_amount = rand(1..10_000)
            referral_amount = paid_amount - (1 + rand(paid_amount - 1000))
            affiliate_amount = paid_amount - referral_amount
            payment_info = affiliate.payment_info

            status = paid_amount > 1000 ? 'Redeemable' : 'Deferred'
            payment.affiliate_id = affiliate.id
            payment.affiliate_payment_info_id = payment_info.id
            payment.amount = paid_amount
            payment.status = status
            payment.period_start_at = Time.now.beginning_of_month
            payment.period_end_at = Time.now.end_of_month
            payment.paid_at = Time.now
            payment.previous_amount = 0.00
            payment.referral_amount = referral_amount
            payment.redeemed_amount = paid_amount
            payment.has_invoice = false
            payment.affiliate_amount = affiliate_amount
            payment.balance = 0.0
            payment.business_entity = affiliate.business_entity
            payment.tax_filing_country = affiliate.tax_filing_country
            payment.payment_type = payment_info.payment_type
            payment.payee_name = payment_info.payee_name
            payment.bank_name = payment_info.bank_name
            payment.bank_identification = payment_info.bank_identification
            payment.branch_name = payment_info.branch_name
            payment.branch_identification = payment_info.branch_identification
            payment.iban = payment_info.iban
            payment.routing_number = payment_info.routing_number
            payment.account_number = payment_info.account_number
            payment.paypal_email_address = payment_info.paypal_email_address
            payment.preferred_currency = payment_info.preferred_currency
            payment.payment_info_status = payment_info.status
            payment.address1 = payment_info.affiliate_address_1
            payment.address2 = payment_info.affiliate_address_2
            payment.zip_code = payment_info.affiliate_zip_code
            payment.country_id = payment_info.affiliate_country_id
            payment.city = payment_info.affiliate_city
            payment.state = payment_info.affiliate_state
          end
        end
      end
    end
  end
end
