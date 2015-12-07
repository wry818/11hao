class AddColumnProductCategoryIdToProduct < ActiveRecord::Migration
  def change
    add_column :products,:product_category_id,:integer
    add_column :products,:pro_cat_subclass_id,:integer
  end
end
