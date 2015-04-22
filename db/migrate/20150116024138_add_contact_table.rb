class AddContactTable < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      
        t.string :first_name
        t.string :last_name
        t.string :email_address
        t.integer :user_id
        t.integer :media_id
        
        t.timestamps
    end
  end
end
