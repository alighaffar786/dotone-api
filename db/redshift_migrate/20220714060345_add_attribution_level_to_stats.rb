class AddAttributionLevelToStats < ActiveRecord::Migration[6.1]
  def change
    add_column :stats, :attribution_level, :string unless Stat.column_names.include?('attribution_level')
  end
end
