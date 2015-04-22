class AddIsOfflineToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :is_offline, :boolean, :default=>false
  end
end
