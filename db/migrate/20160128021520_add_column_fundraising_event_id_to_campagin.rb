class AddColumnFundraisingEventIdToCampagin < ActiveRecord::Migration
  def change
    add_column :campaigns,:fundraising_event_id,:integer
  end
end
