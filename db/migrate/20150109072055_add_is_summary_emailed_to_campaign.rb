class AddIsSummaryEmailedToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_summary_emailed, :boolean, :default=>false
    add_column :campaigns, :summary_emailed_at, :datetime
  end
end
