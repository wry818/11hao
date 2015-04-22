class AddPvTransCalendarTable < ActiveRecord::Migration
  def change
    create_table :pv_transmission_calendars do |t|
      t.string :calendar_name
      t.string :product_group
      t.string :external_id
      t.datetime :delivery_date
      t.datetime :submission_date
    end
  end
end
