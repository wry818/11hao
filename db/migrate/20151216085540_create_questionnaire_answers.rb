class CreateQuestionnaireAnswers < ActiveRecord::Migration
  def change
    create_table :questionnaire_answers do |t|
      t.string :key
      t.string :type
      t.string :value
      t.string :remark
      t.belongs_to :questionnaire
      t.timestamps
    end
  end
end
