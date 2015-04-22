class AddNeedsShippingToProducts < ActiveRecord::Migration
  def change
    add_column :products, :needs_shipping, :boolean, null: false, default: false
  end
end
