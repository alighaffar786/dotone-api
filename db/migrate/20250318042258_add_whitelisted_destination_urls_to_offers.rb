class AddWhitelistedDestinationUrlsToOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :offers, :whitelisted_destination_urls, :json, array: true
  end
end
