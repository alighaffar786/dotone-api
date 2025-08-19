class AddConversionSoFarToOfferCaps < ActiveRecord::Migration[6.1]
  def change
    add_column :offer_caps, :conversion_so_far, :integer
  end
end
