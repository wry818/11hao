class AddActiveToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :active, :boolean, :default=>true
    remove_index :organizations, :entertainment_customer_id
    add_index :organizations, :entertainment_customer_id
  end
end
