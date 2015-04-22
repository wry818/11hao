class CreateOrganizations < ActiveRecord::Migration
    def change
        create_table :organizations do |t|
            t.string :name
            t.string :picture

            t.string :slug
            t.timestamps
        end
        add_index :organizations, :name
        add_index :organizations, :slug, unique: true
    end
end
