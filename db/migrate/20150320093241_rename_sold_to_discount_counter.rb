class RenameSoldToDiscountCounter < ActiveRecord::Migration
  def change
      rename_column :campaigns, :sold_counter, :discount_counter
  end
end
