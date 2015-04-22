class CreateCheckoutOptionGroups < ActiveRecord::Migration
  def change
    create_table :checkout_option_groups do |t|
        t.integer :campaign_id
        t.string :name
        t.string :instructions
        t.integer :sort_order
        t.integer :buyer_scope, null: false, default: 0
        t.boolean :required, null: false, default: false
        t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
