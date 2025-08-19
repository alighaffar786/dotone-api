class CreatePopupFeeds < ActiveRecord::Migration[6.1]
  def change
    create_table :popup_feeds do |t|
      t.string :title
      t.string :button_label
      t.text :cdn_url
      t.string :url
      t.boolean :published, default: false
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
