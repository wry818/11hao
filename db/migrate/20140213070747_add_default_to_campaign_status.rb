class AddDefaultToCampaignStatus < ActiveRecord::Migration
  def change
    change_column :campaigns, :status, :integer, null: false, default: 0
  end
end
