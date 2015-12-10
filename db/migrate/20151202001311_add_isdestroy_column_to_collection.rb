class AddIsdestroyColumnToCollection < ActiveRecord::Migration
  def change
    add_column :collections, :is_destroy, :boolean,:default => false
  end
end
