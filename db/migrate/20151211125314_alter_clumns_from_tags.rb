class AlterClumnsFromTags < ActiveRecord::Migration
  def change
    change_column :tags,:use_count,:integer,default: 0
    change_column :tags,:starmark,:integer,default: 0
  end
end
