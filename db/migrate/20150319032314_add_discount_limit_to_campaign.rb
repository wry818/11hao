class AddDiscountLimitToCampaign < ActiveRecord::Migration
  def change
      add_column :campaigns, :discount, :decimal
      add_column :campaigns, :purchase_limit, :integer
      add_column :campaigns, :sold_counter, :integer, :default=>0
      add_column :items, :is_discount, :boolean, :default=>false
  end
end
