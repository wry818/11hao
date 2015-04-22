class AddInventoryShipFileTable < ActiveRecord::Migration
  def change
    create_table :inventory_shipment_files do |t|
      t.string :file_source
      t.string :file_name
      t.string :file_type
      t.string :cloud_url
      t.string :cloud_public_id

      t.timestamps
    end
  end
end
