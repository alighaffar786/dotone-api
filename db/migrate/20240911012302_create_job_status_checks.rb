class CreateJobStatusChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :job_status_checks do |t|
      t.string :status
      t.json :request_data
      t.string :job_type

      t.timestamps
    end
  end
end
