class CreateOptionGroupProperties < ActiveRecord::Migration
  def change
    create_table :option_group_properties do |t|
        t.integer :option_group_id
        t.string :value
        t.decimal  :price, null: false, default: 0.0
        t.integer :sort_order

      t.timestamps
    end
  end
end
