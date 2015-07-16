class AddDisplaySellerGoalToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :display_seller_goal, :boolean, null: false, default: false
  end
end
