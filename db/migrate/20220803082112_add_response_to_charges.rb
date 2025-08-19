class AddResponseToCharges < ActiveRecord::Migration[6.1]
  def change
    add_column :charges, :response, :json
  end
end
