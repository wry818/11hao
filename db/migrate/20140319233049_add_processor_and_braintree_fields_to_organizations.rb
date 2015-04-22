class AddProcessorAndBraintreeFieldsToOrganizations < ActiveRecord::Migration
    def change
        add_column :organizations, :account_number, :string
        add_column :organizations, :routing_number, :string
        add_column :organizations, :processor_id, :string
        add_column :organizations, :use_braintree, :boolean, null: false, default: false
    end
end
