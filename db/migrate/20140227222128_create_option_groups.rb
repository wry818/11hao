class CreateOptionGroups < ActiveRecord::Migration
  def change
    create_table :option_groups do |t|
        t.integer :product_id
        t.string :name
        t.string :instructions
        t.integer :sort_order
        t.boolean :required, null: false, default: false
        t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
