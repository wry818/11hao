class CreateFundraisingEvents < ActiveRecord::Migration
  def change
    create_table :fundraising_events do |t|
      t.string :name
      t.timestamps
    end
  end
end
