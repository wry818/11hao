class AddOriginalPriceToProduct < ActiveRecord::Migration
  def change
    add_column :products, :original_price, :decimal, null: false, default: 0.0
  end
end
