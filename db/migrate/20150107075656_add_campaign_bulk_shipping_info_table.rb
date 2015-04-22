class AddCampaignBulkShippingInfoTable < ActiveRecord::Migration
  def change
    create_table :campaign_bulkshippinginfos do |t|
      
        t.integer :campaign_id
        t.string :ship_to_name
        t.string :ship_to_attn
        t.string :address_line_1
        t.string :address_line_2
        t.string :city
        t.integer :state_province_id
        t.string :zip_code
        t.integer :country_id
        t.string :phone_number
        t.string :email_address
        t.datetime :delivery_datetime
        
        t.timestamps
    end
  end
end
