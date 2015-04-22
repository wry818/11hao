class AddDeletedToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :deleted, :boolean, :default=>false
    add_index :organizations, :entertainment_customer_id, unique: true
  end
end
