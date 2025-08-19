class AddVerifiedAndAcceptedOriginsToMktSites < ActiveRecord::Migration[6.1]
  def change
    add_column :mkt_sites, :verified, :boolean, default: false
    add_column :mkt_sites, :accepted_origins, :json, array: true
  end
end
