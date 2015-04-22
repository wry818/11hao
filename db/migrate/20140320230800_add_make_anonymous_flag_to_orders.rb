class AddMakeAnonymousFlagToOrders < ActiveRecord::Migration
    def change
        add_column :orders, :make_anonymous, :boolean, null: false, default: false
    end
end
