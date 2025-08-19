require 'rails_helper'

describe AffiliatePayment, type: :model do
  init_setup

  context 'factories' do
    it 'has valid factories' do
      expect(FactoryBot.create(:affiliate_payment)).to be_valid
    end
  end

  context 'after save' do
    let(:deferred_affiliate_payment) do
      FactoryBot.create(:affiliate_payment, :deferred,
        affiliate: @current_affiliate,
        affiliate_amount: 15,
        referral_amount: 5,
        amount: 4,
        with_payment_fee: 1)
    end

    let(:payment) do
      deferred_affiliate_payment.reload
    end

    before(:each) do
      deferred_affiliate_payment.reload.save
    end

    it 'calculate affiliate balance' do
      expect(payment.balance).to eq 15.0
    end
  end
end
