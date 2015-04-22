class AddOrderSubmitTimeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :bulk_submitted_at, :datetime
    add_column :campaigns, :bulk_ordered_at, :datetime
  end
end
