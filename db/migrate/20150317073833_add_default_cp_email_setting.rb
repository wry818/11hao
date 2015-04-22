class AddDefaultCpEmailSetting < ActiveRecord::Migration
  def change
      add_column :admin_settings, :default_email_message_two, :text
      add_column :admin_settings, :default_cp_email_message, :text
      add_column :admin_settings, :default_cp_email_message_two, :text
  end
end
