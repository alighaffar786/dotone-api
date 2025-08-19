class ChangeRequestOriginToIpAddressInDotonePostbacks < ActiveRecord::Migration[6.1]
  def change
    rename_column :dotone_postbacks, :request_origin, :ip_address
  end
end
