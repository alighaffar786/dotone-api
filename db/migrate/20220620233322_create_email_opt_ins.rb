class CreateEmailOptIns < ActiveRecord::Migration[6.1]
  def change
    create_table :email_opt_ins do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :email_template_id
      t.timestamps
    end
  rescue StandardError
    'Migration Not Compatible'
  end
end
