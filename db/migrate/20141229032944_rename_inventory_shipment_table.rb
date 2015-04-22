class RenameInventoryShipmentTable < ActiveRecord::Migration
  def change
    rename_table :inventory_shipment_files, :inventory_ship_order_files
  end
end
