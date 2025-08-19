class AddLanguageIdToAffiliateUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :affiliate_users, :language
  end
end
