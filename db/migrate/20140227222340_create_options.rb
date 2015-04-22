class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
        t.integer :item_id
        t.integer :option_group_id
        t.text :value
        t.decimal :price, null: false, default: 0.0

      t.timestamps
    end
  end
end
