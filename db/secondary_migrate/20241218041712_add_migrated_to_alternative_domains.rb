class AddMigratedToAlternativeDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :alternative_domains, :migrated, :boolean, default: false
  end
end
