class AddEmailTextToSeller < ActiveRecord::Migration
  def change
    add_column :sellers, :email_text, :text
  end
end
