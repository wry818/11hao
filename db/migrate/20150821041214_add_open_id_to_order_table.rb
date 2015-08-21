class AddOpenIdToOrderTable < ActiveRecord::Migration
  def change
    add_column :orders, :open_id, :string
  end
end
