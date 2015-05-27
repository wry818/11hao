class AddOpenIdToVisitLog < ActiveRecord::Migration
  def change
    add_column :campaign_visit_logs, :open_id, :string
  end
end
