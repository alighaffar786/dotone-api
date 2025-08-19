class AddOriginalPriceOfferNameDiscountPriceToTextCreatives < ActiveRecord::Migration[6.1]
  def change
    add_column :text_creatives, :original_price, :string
    add_column :text_creatives, :offer_name, :string
    add_column :text_creatives, :discount_price, :string
  end
end
