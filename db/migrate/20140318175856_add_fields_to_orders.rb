class AddFieldsToOrders < ActiveRecord::Migration
    def change
        add_column :orders, :shipping_fee, :integer, null: false, default: 0
        add_column :orders, :processing_fee_supporter, :integer, null: false, default: 0
        add_column :orders, :processing_fee_organization, :integer, null: false, default: 0
    end
end
