require 'rails_helper'

describe Affiliate, type: :model do
  init_setup

  context 'factories' do
    it 'has valid factories' do
      expect(FactoryBot.create(:affiliate)).to be_valid
    end
  end
end
