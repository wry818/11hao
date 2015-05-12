class ChangeDefaultCallToAction < ActiveRecord::Migration
  def change
    change_column_default :campaigns, :call_to_action, "立即购买"
  end
end
