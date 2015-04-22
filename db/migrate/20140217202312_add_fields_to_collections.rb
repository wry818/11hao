class AddFieldsToCollections < ActiveRecord::Migration
    def change
        add_column :collections, :donation_percentage, :integer
        add_column :collections, :landing_page_html, :text
    end
end
