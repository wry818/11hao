class CreateQuestionnaireAnswers < ActiveRecord::Migration
  def change
    create_table :questionnaire_answers do |t|
      t.string :keyname
      t.string :typename
      t.string :answervalue
      t.string :remark
      t.belongs_to :questionnaire
      t.timestamps
    end
  end
end
