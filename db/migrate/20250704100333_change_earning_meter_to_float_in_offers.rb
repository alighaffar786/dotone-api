class ChangeEarningMeterToFloatInOffers < ActiveRecord::Migration[6.1]
  def change
    change_column :offers, :earning_meter, :float
  end
end
