class ChangeCollationOnProductCategories < ActiveRecord::Migration[6.1]
  def up
    execute 'ALTER TABLE product_categories CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci'
  end

  def down
    execute 'ALTER TABLE product_categories CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci'
  end
end
