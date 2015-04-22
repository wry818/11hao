class ChangeLastInventoryUpdatedAt < ActiveRecord::Migration
  def change
    rename_column :products, :last_inventory_updated_at, :inventory_last_update_time
  end
end
