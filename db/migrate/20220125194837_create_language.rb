class CreateLanguage < ActiveRecord::Migration[6.1]
  def change
    unless Language.table_exists?
      create_table :languages do |t|
        t.string :name
        t.string :code
        t.timestamps
      end
    end
  end
end
