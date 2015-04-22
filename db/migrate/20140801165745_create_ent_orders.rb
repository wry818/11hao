class CreateEntOrders < ActiveRecord::Migration
    def change
        create_table :ent_orders do |t|
            t.integer :campaign_id
            t.integer :seller_id

            t.datetime :order_date
            t.string :status
            t.string :purchaser_first_name
            t.string :purchaser_last_name
            t.string :purchaser_email
            t.decimal :order_total_amt
            t.decimal :unit_price
            t.integer :ordered_qty

            t.string :entertainment_order_id
            t.string :entertainment_group_id
            t.string :entertainment_seller_id

            t.timestamps
        end

        add_index :ent_orders, :entertainment_order_id, unique: true
        add_index :campaigns, :entertainment_group_id, unique: true
    end
end
