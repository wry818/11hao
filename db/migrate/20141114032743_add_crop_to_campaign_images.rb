class AddCropToCampaignImages < ActiveRecord::Migration
  def change
    add_column :campaign_images, :campaign_id, :integer
    add_column :campaign_images, :is_logo, :boolean
    add_column :campaign_images, :image_width, :integer
    add_column :campaign_images, :image_height, :integer
    add_column :campaign_images, :crop_x, :integer
    add_column :campaign_images, :crop_y, :integer
    add_column :campaign_images, :crop_width, :integer
    add_column :campaign_images, :crop_height, :integer
    add_column :campaign_images, :is_cropped, :boolean
  end
end
