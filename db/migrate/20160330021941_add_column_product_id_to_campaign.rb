class AddColumnProductIdToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns,:product_id,:integer
  end
end
