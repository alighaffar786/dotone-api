class CreateFaqFeeds < ActiveRecord::Migration[6.1]
  def change
    create_table :faq_feeds do |t|
      t.string :title
      t.text :content
      t.string :faq_type
      t.boolean :published, default: false
      t.integer :ordinal

      t.timestamps
    end
  end
end
