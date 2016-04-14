class AddColumnIsHotSaleToProduct < ActiveRecord::Migration
  def change
    add_column :products,:is_hot_sale,:boolean
  end
end
