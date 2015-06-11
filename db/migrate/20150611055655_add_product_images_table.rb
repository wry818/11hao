class AddProductImagesTable < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.integer :product_id
      t.string :public_id
      t.boolean :is_cover, :default=>false
    end
  end
end
