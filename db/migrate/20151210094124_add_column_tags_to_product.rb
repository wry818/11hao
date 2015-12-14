class AddColumnTagsToProduct < ActiveRecord::Migration
  def change
    add_column :products,:tags_search,:string
  end
end
