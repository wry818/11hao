class CreateUserProfiles < ActiveRecord::Migration
    def change
        create_table :user_profiles do |t|
            t.integer :user_id, null: false

            t.string :first_name
            t.string :last_name
            t.string :picture
            t.string :display_name
            t.string :title

            t.string :parent_email
            t.string :parent_first_name
            t.string :parent_last_name

            t.boolean :child_profile, null: false, default: false

            t.timestamps
        end

    end
end
