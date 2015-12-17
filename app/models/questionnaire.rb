class Questionnaire < ActiveRecord::Base



  belongs_to  :organization
  has_many :questionnaire_answers

  def get_answer_value(keyname)
    answer=self.questionnaire_answers.where(:keyname=>keyname).first
    if answer
      answer.answervalue
    else
      return ""
    end
  end
  def get_answer_check(keyname,keyvalue)
    answer=self.questionnaire_answers.where(:keyname=>keyname).first
    if answer
      answer.answervalue.include?(keyvalue)
    else
      return false;
    end
  end
  def get_answer(keyname)
    self.questionnaire_answers.where(:keyname=>keyname).first
  end
  def service_population
    self.questionnaire_answers.where(:keyname=>"service_population").first
  end
end
