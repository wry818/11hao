class AddOriginPriceToItem < ActiveRecord::Migration
  def change
      add_column :items, :origin_base_amount, :integer, :default=>0
      add_column :items, :origin_donation_amount, :integer, :default=>0
  end
end
