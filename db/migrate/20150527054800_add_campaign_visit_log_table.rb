class AddCampaignVisitLogTable < ActiveRecord::Migration
  def change
    create_table :campaign_visit_logs do |t|
      t.integer :campaign_id
      t.integer :seller_id
      t.string :remote_ip
      t.datetime :visited_time
    end
  end
end
