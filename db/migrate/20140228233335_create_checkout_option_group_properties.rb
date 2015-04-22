class CreateCheckoutOptionGroupProperties < ActiveRecord::Migration
  def change
    create_table :checkout_option_group_properties do |t|
        t.integer :checkout_option_group_id
        t.string :value
        t.integer :sort_order

      t.timestamps
    end
  end
end
