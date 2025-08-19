module BillingRegioned
  extend ActiveSupport::Concern

  BILLING_REGIONS = {
    'Region 1' => 'US/EU/INTL',
    'Region 2' => 'TW/HK/CN',
    'Region 3' => 'MY/SG/TH/ID',
  }.freeze

  included do
    include ConstantProcessor
    include Scopeable

    validates :billing_region, inclusion: { in: BILLING_REGIONS }, allow_blank: true

    define_constant_methods BILLING_REGIONS.keys, :billing_region

    scope_by_billing_region
  end
end
