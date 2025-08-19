class CreateCreditCards < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_cards do |t|
      t.references  :payment_gateway
      t.string      :unique_identifier
      t.string      :card_token
      t.string      :brand
      t.string      :last_4_digits
      t.date        :expire_at
      t.boolean     :default

      t.timestamps
    end

    add_index :credit_cards, :unique_identifier, unique: true
  end
end
