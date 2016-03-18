class AddColumnReceiverToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns,:receiver,:text
    add_column  :campaigns,:minilogo,:text
    add_column  :campaigns,:is_featured,:boolean
  end
end
