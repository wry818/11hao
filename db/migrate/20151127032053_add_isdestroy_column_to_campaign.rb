class AddIsdestroyColumnToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_destroy, :boolean,:default => false
  end
end
