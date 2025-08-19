class AddCdnUrlToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :attachments, :cdn_url, :string
  end
end
