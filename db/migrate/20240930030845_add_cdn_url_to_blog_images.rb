class AddCdnUrlToBlogImages < ActiveRecord::Migration[6.1]
  def change
    add_column :blog_images, :cdn_url, :text
  end
end
