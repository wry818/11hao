class AddButtonTextToCampaigns < ActiveRecord::Migration
    def change
        add_column :campaigns, :call_to_action, :string, null: false, default: "立刻购买"
    end
end
