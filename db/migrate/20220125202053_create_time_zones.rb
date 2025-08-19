class CreateTimeZones < ActiveRecord::Migration[6.1]
  def change
    unless TimeZone.table_exists?
      create_table :time_zones do |t|
        t.string :gmt
        t.string :name
        t.string :gmt_string
        t.timestamps
      end
    end
  end
end
