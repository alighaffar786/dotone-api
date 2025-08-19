class AddCategoryToFaqFeeds < ActiveRecord::Migration[6.1]
  def change
    add_column :faq_feeds, :category, :string
  end
end
