class CreateTeamMemberGroups < ActiveRecord::Migration
    def change
        create_table :team_member_groups do |t|
            t.integer :campaign_id

            t.string :name
            t.integer :sort_order

            t.timestamps
        end
    end
end
