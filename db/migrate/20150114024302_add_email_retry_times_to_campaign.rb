class AddEmailRetryTimesToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :summary_email_retry_times, :integer, :default=>0
  end
end
