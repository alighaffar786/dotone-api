class Affiliates::ConversionStep::MiniSerializer < Base::ConversionStepSerializer
  attributes :id, :session_option, :days_to_expire, :label
end
