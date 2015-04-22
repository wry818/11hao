class AddAdminSettingsTable < ActiveRecord::Migration
  def change
    create_table :admin_settings do |t|
      t.text :default_email_message
      t.timestamps
    end
  end
end
