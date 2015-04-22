class AddFeaturedToProduct < ActiveRecord::Migration
  def change
    add_column :products, :is_featured, :Boolean, :default=>false, :null=>false
  end
end
