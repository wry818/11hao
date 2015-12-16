class Admin::QuestionnairesController < Admin::ApplicationController
def index

  end
  def new
         @questionnaire=Questionnaire.new
  end
end
