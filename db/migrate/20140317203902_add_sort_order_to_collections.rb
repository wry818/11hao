class AddSortOrderToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :sort_order, :integer
  end
end
