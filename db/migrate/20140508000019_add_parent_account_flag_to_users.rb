class AddParentAccountFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :parent_account, :boolean, null: false, default: false
  end
end
