class NewSellerStrategy < ActiveRecord::Migration
    def change
        remove_column :users, :parent_account, :boolean, default: false, null: false
        remove_column :users, :first_name, :string
        remove_column :users, :last_name, :string
        remove_column :users, :display_name, :string
        remove_column :users, :title, :string
        remove_column :users, :picture, :string
        remove_column :users, :slug, :string

        add_column :users, :account_type, :integer

        remove_column :sellers, :user_id, :integer
        remove_column :sellers, :first_name, :string
        remove_column :sellers, :last_name, :string

        add_column :sellers, :user_profile_id, :integer
        add_column :sellers, :grade, :string
        add_column :sellers, :homeroom, :string

        add_index :sellers, :referral_code, unique: true
        add_index :sellers, [:user_profile_id, :campaign_id]
        add_index :sellers, [:campaign_id, :user_profile_id]

    end
end
