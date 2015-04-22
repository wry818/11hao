class CreateCheckoutOptions < ActiveRecord::Migration
  def change
    create_table :checkout_options do |t|
        t.integer :order_id
        t.integer :checkout_option_group_id
        t.text :value

      t.timestamps
    end
  end
end
