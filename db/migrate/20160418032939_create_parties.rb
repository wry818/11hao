class CreateParties < ActiveRecord::Migration
  def change
    create_table :parties do |t|
        t.integer :user_id
        t.string :name
        t.datetime :begin_time
        t.datetime :end_time
        t.datetime :register_end
        t.string :provice
        t.string :city
        t.string :country
        t.string :address
        t.string :logo
        t.string :content
        t.boolean :has_fee
        t.boolean :allow_spread
        t.integer :max_count
        t.integer :fee_count
        t.timestamps
        t.boolean :is_destroy, default: false
    end
  end
end
