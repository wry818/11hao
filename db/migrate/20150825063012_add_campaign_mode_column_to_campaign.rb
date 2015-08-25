class AddCampaignModeColumnToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :campaign_mode, :integer
  end
end
