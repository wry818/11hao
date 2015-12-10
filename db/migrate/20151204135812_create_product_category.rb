class CreateProductCategory < ActiveRecord::Migration
  def change
    create_table :product_categories do |t|
          t.string :name
          t.integer :sort_mark
          t.boolean :active, null: false, default: false
          t.references :product_category
          t.boolean :is_destroy,:default=>false
          t.timestamps

    end
  end
end
