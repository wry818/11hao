class AddDirectDonationFieldsToOrder < ActiveRecord::Migration
    def change
        add_column :orders, :direct_donation, :integer, null: false, default: 0
    end
end
