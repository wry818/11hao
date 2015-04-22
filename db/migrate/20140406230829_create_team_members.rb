class CreateTeamMembers < ActiveRecord::Migration
    def change
        create_table :team_members do |t|
            t.integer :user_id
            t.integer :campaign_id

            t.integer :team_member_group_id
            t.string :referral_code

            t.text :welcome_message
            t.string :picture

            t.timestamps
        end
        add_index :team_members, [:user_id, :campaign_id]
        add_index :team_members, [:campaign_id, :user_id]
    end
end
