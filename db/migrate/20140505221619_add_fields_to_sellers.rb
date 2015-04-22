class AddFieldsToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :referral_code, :string
  end
end
