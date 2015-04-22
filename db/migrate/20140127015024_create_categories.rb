class CreateCategories < ActiveRecord::Migration
    def change
        create_table :categories do |t|
            t.string :name
            t.text :description
            t.string :picture

            t.integer :collection_id
            t.integer :parent_category_id
            t.boolean :featured, null: false, default: false

            t.string :slug
            t.timestamps
        end
        add_index :categories, :slug, unique: true
    end
end