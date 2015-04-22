class CampaignBulkshippinginfo < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :country
  belongs_to :state_province
  
  def delivery_date
    @delivery_date
  end
  
  def delivery_date=(val)
    @delivery_date = val
  end
  
  def delivery_time
    @delivery_time
  end
  
  def delivery_time=(val)
    @delivery_time = val
  end
  
end
