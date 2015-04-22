class AddFieldsToCampaigns < ActiveRecord::Migration
    def change
        add_column :campaigns, :charge_processing_to_supporter, :boolean, null: false, default: false
        add_column :campaigns, :charge_processing_to_organization, :boolean, null: false, default: false
    end
end
