class AddSourceToAffiliates < ActiveRecord::Migration[6.1]
  def up
    add_column :affiliates, :source, :string, default: Affiliate.source_marketplace

    Affiliate.update_all(source: Affiliate.source_marketplace)
  end

  def down
    remove_column :affiliates, :source
  end
end
