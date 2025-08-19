class AddAffiliateIdToSiteInfos < ActiveRecord::Migration[6.1]
  def change
    add_reference :site_infos, :affiliate
  end
end
