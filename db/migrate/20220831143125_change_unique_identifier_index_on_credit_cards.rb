class ChangeUniqueIdentifierIndexOnCreditCards < ActiveRecord::Migration[6.1]
  def change
    remove_index :credit_cards, :unique_identifier
    add_index :credit_cards, %i[unique_identifier payment_gateway_id], unique: true
  end
end
