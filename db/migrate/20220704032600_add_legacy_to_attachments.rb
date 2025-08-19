class AddLegacyToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :attachments, :legacy, :boolean, default: true
    remove_column :attachments, :cdn_url

    Attachment.update_all(legacy: true)
  end
end
