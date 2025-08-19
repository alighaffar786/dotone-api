class CreateCurrencies < ActiveRecord::Migration[6.1]
  def change
    unless Currency.table_exists?
      create_table :currencies do |t|
        t.string 'name'
        t.string 'code'
        t.timestamps
      end
    end
  end
end
