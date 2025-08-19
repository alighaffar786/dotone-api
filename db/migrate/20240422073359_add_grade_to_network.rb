class AddGradeToNetwork < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :grade, :string
  end
end
