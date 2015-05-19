class AddAddressCityAreaToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :address_city_area, :string
  end
end
