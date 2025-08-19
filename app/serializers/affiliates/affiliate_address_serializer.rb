class Affiliates::AffiliateAddressSerializer < ApplicationSerializer
  attributes :id, :address_1, :address_2, :city, :state, :zip_code, :country_id, :application_phone_number

  def application_phone_number
    object.affiliate.phone_number_last_used.presence || object.affiliate.phone_number
  end
end
