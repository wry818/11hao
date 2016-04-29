class CreatePartyTickets < ActiveRecord::Migration
  def change
    create_table :party_tickets do |t|
      t.references :parties
      t.string :name
      t.integer :fee
      t.integer :max_count
      t.timestamps
    end
  end
end
