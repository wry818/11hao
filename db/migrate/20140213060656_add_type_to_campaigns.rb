class AddTypeToCampaigns < ActiveRecord::Migration
    def change
        add_column :campaigns, :campaign_type, :integer, null: false, default: 0
    end
end
