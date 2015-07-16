class AddAvatarUrlToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :avatar_url, :string
  end
end
