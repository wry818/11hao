class CreateCampaigns < ActiveRecord::Migration
    def change
        create_table :campaigns do |t|
            t.integer :organizer_id
            t.integer :collection_id
            t.integer :organization_id

            t.string :title, index: true
            t.decimal :goal
            t.text :organizer_quote
            t.text :description
            t.text :delivery_details
            t.datetime :start_date
            t.datetime :end_date

            t.string :picture

            t.integer :status

            t.string :slug
            t.timestamps
        end
        add_index :campaigns, :slug, unique: true
    end
end
