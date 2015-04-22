class CreateItems < ActiveRecord::Migration
    def change
        create_table :items do |t|
            t.integer :order_id
            t.integer :product_id
            t.integer :base_amount, :null => false, :default => 0
            t.integer :donation_amount, :null => false, :default => 0
            t.integer :quantity

            t.timestamps
        end
    end
end
