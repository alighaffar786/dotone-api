class Teams::AffiliateAddressSerializer < ApplicationSerializer
  attributes :id, :address_1, :address_2, :city, :state, :zip_code, :country_id

  has_one :country
end
