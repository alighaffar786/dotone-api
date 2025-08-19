class AddCardKeyToCreditCards < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_cards, :card_key, :string, after: :card_token
  end
end
