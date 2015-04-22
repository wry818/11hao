class AddAddressFullnameToOrders < ActiveRecord::Migration
    def change
        add_column :orders, :address_fullname, :string
    end
end
