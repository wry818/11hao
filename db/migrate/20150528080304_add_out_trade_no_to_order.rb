class AddOutTradeNoToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :out_trade_no, :string
  end
end
