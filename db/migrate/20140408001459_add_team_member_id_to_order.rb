class AddTeamMemberIdToOrder < ActiveRecord::Migration
    def change
        add_column :orders, :team_member_id, :integer
    end
end
