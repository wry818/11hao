class AddImportFields < ActiveRecord::Migration
    def change
        add_column :campaigns, :entertainment_group_id, :string
        add_column :organizations, :entertainment_customer_id, :string
        add_column :organizations, :address_country, :string
    end
end
