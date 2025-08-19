class AffiliateAddress < DatabaseRecords::PrimaryRecord
  include Relations::CountryAssociated

  belongs_to :affiliate, inverse_of: :affiliate_address, touch: true

  def street_address
    [address_1, address_2].reject(&:blank?).join(', ')
  end

  def state_zip
    [state, zip_code].reject(&:blank?).join(' ')
  end

  def city_state_zip
    [city, state_zip].reject(&:blank?).join(', ')
  end

  def full_address
    [street_address, city_state_zip].reject(&:blank?).join(', ')
  end

  def full_address_with_country
    [full_address, country_name].reject(&:blank?).join(', ')
  end

  def country_name
    country&.name
  end

  def address_attributes
    attributes.slice('address_1', 'address_2', 'city', 'state', 'zip_code', 'country_id')
  end
end
