class AddNicknameToVisitLog < ActiveRecord::Migration
  def change
    add_column :campaign_visit_logs, :nickname, :string
  end
end
