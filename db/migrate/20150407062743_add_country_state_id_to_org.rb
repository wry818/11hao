class AddCountryStateIdToOrg < ActiveRecord::Migration
  def change
    add_column :organizations, :country_id, :integer
    add_column :organizations, :state_province_id, :integer
    add_column :countries, :abbrev, :string
    
    Country.find_by_id(1).update_attribute(:abbrev, 'US')
    Country.find_by_id(2).update_attribute(:abbrev, 'CA')
  end
end
