class AddDeliveryMethodToProduct < ActiveRecord::Migration
  def change
    add_column :products, :delivery_method, :integer
    add_column :orders, :phone_number, :string
  end
end
