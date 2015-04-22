class AddProperyIdToOption < ActiveRecord::Migration
  def change
    add_column :options, :option_group_property_id, :integer
    add_column :option_group_properties, :deleted, :boolean, :default=>false
  end
end
