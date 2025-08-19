require "#{Rails.root}/lib/mysql_big_table_migration_helper.rb"

class AddOrderNumberIndexToAffiliateStatPartitions < ActiveRecord::Migration[6.1]
  include MysqlBigTableMigrationHelper

  def up
    add_index_using_tmp_table :affiliate_stat_captured_ats, :order_number
  end

  def down
    remove_index_using_tmp_table :affiliate_stat_captured_ats, column: :order_number
  end
end
