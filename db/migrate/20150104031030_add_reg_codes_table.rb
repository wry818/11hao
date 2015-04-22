class AddRegCodesTable < ActiveRecord::Migration
  def change
    create_table :registration_codes do |t|
      t.string :reg_code
      t.integer :product_id
      t.integer :is_used, :default=>0
      t.integer :order_id
      t.integer :item_id
      
      t.timestamps
    end
  end
end
