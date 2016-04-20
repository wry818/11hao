class AddParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.references :parties
      t.references :orders
      t.string :name
      t.string :tel
      t.string :remark
      t.string :code
      t.string :fullname
      t.string :avatar_url
      t.string :open_id
      t.integer :status
      t.timestamps
    end
  end
end
