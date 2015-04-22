class AddInventoryQtyToOgProperty < ActiveRecord::Migration
  def change
    add_column :option_group_properties, :qty_available, :integer, :default=>0
    add_column :option_group_properties, :qty_counter, :integer, :default=>0
    add_column :option_group_properties, :inventory_last_update_time, :datetime
  end
end
