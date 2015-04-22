class UpdateSellers < ActiveRecord::Migration
    def change
        drop_table :sellers

        create_table :sellers do |t|
            t.integer :user_id

            t.string :first_name
            t.string :last_name

            t.timestamps
        end

        create_join_table :campaigns, :sellers do |t|
          t.index [:campaign_id, :seller_id]
          t.index [:seller_id, :campaign_id]
        end

    end
end
