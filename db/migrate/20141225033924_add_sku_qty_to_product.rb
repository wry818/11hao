class AddSkuQtyToProduct < ActiveRecord::Migration
  def change
    add_column :products, :sku, :string
    add_column :products, :qty_available, :integer, :default=>0
    add_column :products, :qty_counter, :integer, :default=>0
    add_column :products, :last_inventory_updated_at, :datetime
  end
end
