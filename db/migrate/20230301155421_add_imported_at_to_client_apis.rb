class AddImportedAtToClientApis < ActiveRecord::Migration[6.1]
  def change
    add_column :client_apis, :imported_at, :datetime
  end
end
