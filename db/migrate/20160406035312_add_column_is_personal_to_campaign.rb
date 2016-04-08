class AddColumnIsPersonalToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns,:is_personal,:boolean
  end
end
