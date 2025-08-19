class CreatePhoneVerifications < ActiveRecord::Migration[6.1]
  def change
    create_table :phone_verifications do |t|
      t.string :phone_number, null: false
      t.string :otp
      t.datetime :expired_at, null: false
      t.datetime :verified_at
      t.integer :attempts, default: 0, null: false
      t.references :owner, polymorphic: true, null: false, index: true

      t.timestamps
    end

    add_index :phone_verifications, :phone_number
    add_index :phone_verifications, :expired_at
    add_index :phone_verifications, [:owner_type, :owner_id, :phone_number], unique: true, name: 'index_phone_verification_phone_number_unique_owner'
  end
end
