class AddMallSettingTable < ActiveRecord::Migration
  def change
    create_table :mall_top_categories do |t|
      t.integer :product_category_id
      t.integer :sort_order
    end

    create_table :mall_slider_images do |t|
      t.string :public_id
      t.string :image_url
      t.integer :image_width
      t.integer :image_height
      t.integer :sort_order
      t.integer :crop_x
      t.integer :crop_y
      t.integer :crop_width
      t.integer :crop_height
      t.boolean :is_cropped, :default=>false
      t.boolean :active, :default=>true
    end

    create_table :mall_hot_products do |t|
      t.integer :product_id
      t.integer :sort_order
    end
    
    add_column :product_categories, :picture, :string
  end
end
