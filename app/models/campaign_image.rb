class CampaignImage < ActiveRecord::Base
  scope :default_images, -> { where(active: true, campaign_id: nil) }
  
  belongs_to :campaign
end
