class CreateCollections < ActiveRecord::Migration
    def change
        create_table :collections do |t|
            t.string :name
            t.text :description
            t.string :picture
            t.boolean :active, null: false, default: false

            t.string :slug
            t.timestamps
        end
        add_index :collections, :slug, unique: true
    end
end
