class AddEmailShareHistoryTable < ActiveRecord::Migration
  def change
    create_table :email_share_histories do |t|
      
        t.integer :contact_id
        t.integer :seller_id
        t.datetime :date_sent
        
        t.timestamps
    end
  end
end
