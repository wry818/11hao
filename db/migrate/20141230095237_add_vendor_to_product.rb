class AddVendorToProduct < ActiveRecord::Migration
  def change
    add_column :products, :vendor, :string
  end
end
