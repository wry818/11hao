class CreateProductTags < ActiveRecord::Migration
  def change
    create_table :product_tags do |t|
      t.belongs_to :product
      t.belongs_to :tag

      t.timestamps
    end
  end
end
