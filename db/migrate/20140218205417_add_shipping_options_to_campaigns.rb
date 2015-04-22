class AddShippingOptionsToCampaigns < ActiveRecord::Migration
    def change
        add_column :campaigns, :digital_delivery_instructions, :text
        add_column :campaigns, :has_pickup, :boolean, null: false, default: false
        add_column :campaigns, :pickup_instructions, :text
        add_column :campaigns, :has_shipping, :boolean, null: false, default: false
        add_column :campaigns, :shipping_instructions, :text
        add_column :campaigns, :shipping_flat_rate, :decimal
        add_column :campaigns, :shipping_variable_rate, :decimal
    end
end
