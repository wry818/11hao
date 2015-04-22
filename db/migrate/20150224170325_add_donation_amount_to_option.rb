class AddDonationAmountToOption < ActiveRecord::Migration
  def change
    add_column :options, :donation_amount, :decimal, :default=>0.0
  end
end
