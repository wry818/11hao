class AddRecIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :rec_id, :string
  end
end
