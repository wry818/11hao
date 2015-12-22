class AddColumnExpressToItems < ActiveRecord::Migration
  def change
    add_column :items,:express,:string
  end
end
