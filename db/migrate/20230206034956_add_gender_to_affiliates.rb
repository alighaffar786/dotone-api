class AddGenderToAffiliates < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :gender, :string
  end
end
