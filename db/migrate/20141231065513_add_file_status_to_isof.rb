class AddFileStatusToIsof < ActiveRecord::Migration
  def change
    add_column :inventory_ship_order_files, :file_status, :integer, :default=>0
  end
end
