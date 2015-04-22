class CreateOrganizationRoles < ActiveRecord::Migration
    def change
        create_table :organization_roles do |t|
            t.integer :organization_id
            t.integer :user_id
            t.integer :access_level, null: false, default: 0

            t.timestamps
        end
        add_index :organization_roles, [:organization_id, :user_id]
        add_index :organization_roles, [:user_id, :organization_id]

        drop_join_table :organizations, :users
    end
end
