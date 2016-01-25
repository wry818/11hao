class AddColumnOpenIdToSeller < ActiveRecord::Migration
  def change
    add_column :sellers,:open_id,:string
  end
end
