class InsertCountryTableData < ActiveRecord::Migration
  def up
    Country.create id: 1, name: "United States", created_at: Time.now
    Country.create id: 2, name: "Canada", created_at: Time.now
  end
end
