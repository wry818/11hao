class CreateCampaignImages < ActiveRecord::Migration
  def change
    create_table :campaign_images do |t|
      t.string :public_id
      t.string :image_id
      t.boolean :active, :default=>true, :null=>false

      t.timestamps
    end
  end
end
