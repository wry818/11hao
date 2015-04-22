class AddTrackingNumToItem < ActiveRecord::Migration
  def change
    add_column :items, :tracking_number, :string
  end
end
