class RenameDeliveryMethodOfProduct < ActiveRecord::Migration
  def change
    rename_column :products, :delivery_method, :fulfillment_method
  end
end
