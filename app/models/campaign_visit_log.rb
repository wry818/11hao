class CampaignVisitLog < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :seller
end
