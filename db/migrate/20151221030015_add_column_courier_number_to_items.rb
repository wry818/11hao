class AddColumnCourierNumberToItems < ActiveRecord::Migration
  def change
    add_column :items,:courier_number,:string
  end
end
