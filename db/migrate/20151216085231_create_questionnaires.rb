class CreateQuestionnaires < ActiveRecord::Migration
  def change
    create_table :questionnaires do |t|
      t.belongs_to :organization
      t.string :name

      t.timestamps
    end
  end
end
