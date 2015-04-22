class AddShowQuantityFlagToProducts < ActiveRecord::Migration
  def change
    add_column :products, :show_quantity, :boolean, null: false, default: true
  end
end
