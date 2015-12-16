class Questionnaire < ActiveRecord::Base


  belongs_to  :organization
  has_many :questionnaire_answers
end
