class CreateProducts < ActiveRecord::Migration
    def change
        create_table :products do |t|

            t.string :name
            t.text :description
            t.string :picture

            t.decimal :base_price, null: false, default: 0.0
            t.decimal :default_donation_amount, null: false, default: 0.0

            t.string :slug
            t.timestamps
        end
        add_index :products, :slug, unique: true
    end
end
