require "#{Rails.root}/lib/mysql_big_table_migration_helper.rb"

class AddOrderTotalToAffiliateStats < ActiveRecord::Migration[6.1]
  include MysqlBigTableMigrationHelper

  def up
    add_column_using_tmp_table :affiliate_stat_converted_ats, :order_total, :decimal, precision: 20, scale: 2
    add_column_using_tmp_table :affiliate_stat_published_ats, :order_total, :decimal, precision: 20, scale: 2
    add_column_using_tmp_table :affiliate_stat_captured_ats, :order_total, :decimal, precision: 20, scale: 2
  end

  def down
    remove_column_using_tmp_table :affiliate_stat_converted_ats, :order_total
    remove_column_using_tmp_table :affiliate_stat_published_ats, :order_total
    remove_column_using_tmp_table :affiliate_stat_captured_ats, :order_total
  end
end
