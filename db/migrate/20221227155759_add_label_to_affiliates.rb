class AddLabelToAffiliates < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :label, :string
  end
end
