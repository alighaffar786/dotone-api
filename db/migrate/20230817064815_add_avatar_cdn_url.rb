class AddAvatarCdnUrl < ActiveRecord::Migration[6.1]
  def change
    add_column :networks, :avatar_cdn_url, :text
    add_column :affiliates, :avatar_cdn_url, :text
  end
end
