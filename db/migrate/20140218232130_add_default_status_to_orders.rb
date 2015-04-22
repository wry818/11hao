class AddDefaultStatusToOrders < ActiveRecord::Migration
  def change
    change_column :orders, :status, :integer, null: false, default: 0
  end
end
