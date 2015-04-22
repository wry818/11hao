class CreateCampaignStories < ActiveRecord::Migration
  def change
    create_table :campaign_stories do |t|
      t.text :story
      t.string :title

      t.timestamps
    end
  end
end
