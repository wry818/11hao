class AddColumnAgreementidToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns,:agreement_id,:integer
  end
end
