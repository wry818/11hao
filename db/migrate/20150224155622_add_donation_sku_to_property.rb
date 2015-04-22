class AddDonationSkuToProperty < ActiveRecord::Migration
  def change
    add_column :option_group_properties, :donation_amount, :decimal, :default=>0.0
    add_column :option_group_properties, :sku, :string
  end
end
