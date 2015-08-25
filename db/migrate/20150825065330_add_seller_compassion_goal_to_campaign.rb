class AddSellerCompassionGoalToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :seller_compassion_goal, :integer
  end
end
