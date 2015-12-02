class AddIsdestroyColumnToProduct < ActiveRecord::Migration
  def change
    add_column :products, :is_destroy, :boolean,:default => false
  end
end
