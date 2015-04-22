class AddIndexToCampaignTitle < ActiveRecord::Migration
  def change
    add_index :campaigns, :title
  end
end
