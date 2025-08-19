class CreateCharges < ActiveRecord::Migration[6.1]
  def change
    create_table :charges do |t|
      t.references  :network
      t.references  :credit_card
      t.decimal     :amount
      t.string      :currency_code
      t.string      :status
      t.boolean     :is_captured
      t.decimal     :amount_captured
      t.boolean     :is_refunded
      t.decimal     :amount_refunded

      t.timestamps
    end
  end
end
