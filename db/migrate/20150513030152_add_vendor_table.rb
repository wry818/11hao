class AddVendorTable < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :email
      t.boolean :active, default: true
      t.boolean :deleted, default: false
    end
    
    add_column :products, :vendor_id, :integer
  end
end
