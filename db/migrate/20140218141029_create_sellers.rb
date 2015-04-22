class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
        t.integer :campaign_id
        t.string :name

      t.timestamps
    end
  end
end
