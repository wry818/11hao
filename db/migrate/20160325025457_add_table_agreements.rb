class AddTableAgreements < ActiveRecord::Migration
  def change
    create_table :agreements  do |t|
    t.string :name
    t.string :content
    t.timestamps
    end
  end
end
