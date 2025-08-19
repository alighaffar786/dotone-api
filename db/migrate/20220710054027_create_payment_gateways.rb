class CreatePaymentGateways < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_gateways do |t|
      t.references  :network
      t.string      :customer_token
      t.integer     :name

      t.timestamps
    end
  end
end
