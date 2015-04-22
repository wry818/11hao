class AddDeliveryMethodToOrders < ActiveRecord::Migration
    def change
        add_column :orders, :delivery_method, :integer, null: false, default: 0
    end
end
