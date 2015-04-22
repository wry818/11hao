class AddIdentifierToCampaignImages < ActiveRecord::Migration
  def change
    add_column :campaign_images, :image_identifier, :string
  end
end
