class AddSellerGoalToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :seller_goal, :decimal
  end
end
