class AddIsdestroyColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_destroy, :boolean,:default => false
  end
end
