class AddAllowDirectDonationToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :allow_direct_donation, :Boolean
  end
end
