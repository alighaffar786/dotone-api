require "#{Rails.root}/lib/mysql_big_table_migration_helper.rb"

class AddOrderTotalToMainAffiliateStats < ActiveRecord::Migration[6.1]
  include MysqlBigTableMigrationHelper

  def up
    add_column_using_tmp_table :affiliate_stats, :order_total, :decimal, precision: 20, scale: 2
  end
  
  def down
    remove_column_using_tmp_table :affiliate_stats, :order_total
  end
end
