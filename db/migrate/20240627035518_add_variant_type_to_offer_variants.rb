class AddVariantTypeToOfferVariants < ActiveRecord::Migration[6.1]
  def change
    add_column :offer_variants, :variant_type, :string, null: false, default: OfferVariant.variant_type_home_page
  end
end
