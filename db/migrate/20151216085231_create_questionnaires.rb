class CreateQuestionnaires < ActiveRecord::Migration
  def change
    create_table :questionnaires do |t|
      t.belongs_to :Organization
      t.string :name

      t.timestamps
    end
  end
end
