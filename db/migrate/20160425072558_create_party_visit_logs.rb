class CreatePartyVisitLogs < ActiveRecord::Migration
  def change
    create_table :party_visit_logs do |t|
      t.references :parties
      t.string :remote_ip
      t.string :visited_time
      t.string :nickname
      t.string :open_id
    end
  end
end
