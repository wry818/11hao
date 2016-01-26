class AddColumnIsSuccessToSelleReferrall < ActiveRecord::Migration
  def change
    add_column :seller_referrals,:is_success,:boolean
  end
end
