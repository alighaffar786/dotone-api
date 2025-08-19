class AddPlatformToMktSites < ActiveRecord::Migration[6.1]
  def change
    add_column :mkt_sites, :platform, :string
  end
end
