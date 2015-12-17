class QuestionnaireAnswer < ActiveRecord::Base

  attr_accessible :key

  belongs_to  :questionnaire


end
