class CreateShareLog < ActiveRecord::Migration
  def change
    create_table :share_logs do |t|
      t.integer :refid
      t.integer :type
      t.string :remote_ip
      t.string :share_time
      t.string :nickname
      t.string :open_id
    end
  end
end
