class Advertisers::ConversionStepSerializer < Base::ConversionStepSerializer
  attributes :id, :session_option, :days_to_expire, :true_pay, :label
end
