class AddOptoutFromOfferNewsletterToAffiliates < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :optout_from_offer_newsletter, :boolean, default: false
  end
end
