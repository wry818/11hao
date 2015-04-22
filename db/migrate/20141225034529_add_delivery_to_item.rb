class AddDeliveryToItem < ActiveRecord::Migration
  def change
    add_column :items, :delivery_method, :integer, :default=>1
    add_column :items, :delivery_status, :integer, :default=>1
    add_column :items, :delivery_updated_at, :datetime
  end
end
