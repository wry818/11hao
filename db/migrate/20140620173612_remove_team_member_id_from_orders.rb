class RemoveTeamMemberIdFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :team_member_id
  end
end
