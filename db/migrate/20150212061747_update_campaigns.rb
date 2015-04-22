class UpdateCampaigns < ActiveRecord::Migration
  def change
    change_column_default(:campaigns, :allow_direct_donation, false)
  end
end
