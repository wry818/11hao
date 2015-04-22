class AddButtonTextToCampaigns < ActiveRecord::Migration
    def change
        add_column :campaigns, :call_to_action, :string, null: false, default: "Shop Now"
    end
end
