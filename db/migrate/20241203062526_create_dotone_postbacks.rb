class CreateDotonePostbacks < ActiveRecord::Migration[6.1]
  def up
    create_table :dotone_postbacks, id: false, primary_key: false, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci' do |t|
      t.integer :id, null: false, auto_increment: true, index: true
      t.string :postback_type
      t.text :raw_response
      t.text :raw_request
      t.text :request_origin
      t.string :affiliate_stat_id, index: true
      t.datetime :recorded_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps precision: 0
    end

    execute <<-SQL.squish
      ALTER TABLE dotone_postbacks
      ADD PRIMARY KEY (recorded_at, id)
    SQL
  end

  def down
    drop_table :dotone_postbacks
  end
end
