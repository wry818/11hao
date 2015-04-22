class CreateUsers < ActiveRecord::Migration
    def change
        create_table :users do |t|
            t.string :first_name
            t.string :last_name
            t.string :email
            t.string :password_digest
            t.string :remember_token

            t.string :picture

            t.string :provider
            t.string :uid
            t.string :oauth_token
            t.datetime :oauth_expires_at

            t.string :slug
            t.timestamps
        end
        add_index :users, :email, unique: true
        add_index :users, :slug, unique: true
        add_index :users, :remember_token, unique: true
        add_index :users, :uid, unique: true
    end
end
