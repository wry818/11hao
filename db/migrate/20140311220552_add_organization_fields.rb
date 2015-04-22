class AddOrganizationFields < ActiveRecord::Migration
    def change
        add_column :organizations, :logo, :string
        add_column :organizations, :address_line_one, :string
        add_column :organizations, :address_line_two, :string
        add_column :organizations, :address_city, :string
        add_column :organizations, :address_state, :string
        add_column :organizations, :address_postal_code, :string
        add_column :organizations, :phone, :string
        add_column :organizations, :email, :string
        add_column :organizations, :website, :string

        add_column :organizations, :legal_name, :string
        add_column :organizations, :legal_tax_id, :string

        add_column :organizations, :legal_address_line_one, :string
        add_column :organizations, :legal_address_line_two, :string
        add_column :organizations, :legal_address_city, :string
        add_column :organizations, :legal_address_state, :string
        add_column :organizations, :legal_address_postal_code, :string

        add_column :organizations, :legal_rep_first_name, :string
        add_column :organizations, :legal_rep_last_name, :string
        add_column :organizations, :legal_rep_dob, :string
        add_column :organizations, :legal_rep_tax_id, :string
        add_column :organizations, :legal_rep_phone, :string
        add_column :organizations, :legal_rep_email, :string
    end
end
