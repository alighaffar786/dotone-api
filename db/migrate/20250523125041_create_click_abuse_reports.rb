class CreateClickAbuseReports < ActiveRecord::Migration[6.1]
  def change
    create_table :click_abuse_reports do |t|
      t.string :token, null: false
      t.text :raw_request
      t.text :user_agent
      t.string :ip_address
      t.text :error_details
      t.text :referer
      t.integer :count, default: 0
      t.boolean :blocked, default: false
      t.timestamps
    end
  end
end
