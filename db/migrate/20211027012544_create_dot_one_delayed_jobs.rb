class CreateDotOneDelayedJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :dot_one_delayed_jobs, force: true do |table|
      table.integer :priority, default: 0, null: false
      table.integer :attempts, default: 0, null: false
      table.longtext :handler, null: false
      table.longtext :last_error
      table.datetime :run_at
      table.datetime :locked_at
      table.datetime :failed_at
      table.string :locked_by
      table.string :queue
      table.timestamps null: true
      table.string :owner_type
      table.string :owner_id
      table.integer :wl_company_id
      table.string :job_type
      table.string :locale
      table.integer :user_id
      table.string :user_type
      table.string :currency_code, limit: 3
    end
  end
end
