class NoneCampaignShop < ActiveRecord::Migration
  def change
    org = Organization.create id: 0, name: "default"
    campaign = Campaign.create id: 0, organizer_id: 1, organization_id: 0, title: 'default'
    
    org.name = "11号公益圈"
    org.save
    
    campaign.title = "11号公益圈"
    campaign.save
  end
end
