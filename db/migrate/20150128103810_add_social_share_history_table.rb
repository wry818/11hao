class AddSocialShareHistoryTable < ActiveRecord::Migration
  def change
    create_table :social_share_histories do |t|
      t.integer :seller_id
      t.integer :media_id
      t.string :post_id
      t.datetime :date_shared
    end
  end
end
