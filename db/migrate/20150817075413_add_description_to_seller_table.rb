class AddDescriptionToSellerTable < ActiveRecord::Migration
  def change
    add_column :sellers, :description, :text
  end
end
