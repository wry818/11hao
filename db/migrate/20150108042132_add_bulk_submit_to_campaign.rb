class AddBulkSubmitToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_bulk_submitted, :boolean, :default=>false
    add_column :campaigns, :is_bulk_ordered, :boolean, :default=>false
  end
end
