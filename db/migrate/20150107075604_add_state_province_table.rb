class AddStateProvinceTable < ActiveRecord::Migration
  def change
    create_table :state_provinces do |t|
        t.integer :country_id
        t.string :abbrev
        t.string :name
        
        t.timestamps
    end
  end
end
