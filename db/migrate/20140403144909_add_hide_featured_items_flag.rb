class AddHideFeaturedItemsFlag < ActiveRecord::Migration
    def change
        add_column :campaigns, :hide_featured_items, :boolean, null: false, default: false
    end
end
