class CreateSellerReferral < ActiveRecord::Migration
  def change
    create_table :seller_referrals do |t|
      t.references :seller
      t.references :sellerreferral
      t.timestamps
    end
  end
end
