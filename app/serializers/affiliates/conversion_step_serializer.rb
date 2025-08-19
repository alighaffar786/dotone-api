class Affiliates::ConversionStepSerializer < Base::ConversionStepSerializer
  attributes :id, :session_option, :days_to_expire, :affiliate_pay, :label
end
