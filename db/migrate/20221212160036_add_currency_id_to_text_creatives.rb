class AddCurrencyIdToTextCreatives < ActiveRecord::Migration[6.1]
  def up
    add_column :text_creatives, :currency_id, :integer
    add_index :text_creatives, :currency_id

    TextCreative.update_all(currency_id: Currency.platform.id)
  end

  def down
    remove_column :text_creatives, :currency_id
    remove_index :text_creatives, :currency_id
  end
end
