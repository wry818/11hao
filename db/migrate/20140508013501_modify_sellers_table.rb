class ModifySellersTable < ActiveRecord::Migration
  def change
    add_column :sellers, :campaign_id, :integer
    drop_table :team_members
    drop_table :team_member_groups
    drop_table :campaigns_sellers

    add_index :sellers, [:user_id, :campaign_id]
    add_index :sellers, [:campaign_id, :user_id]

  end
end
