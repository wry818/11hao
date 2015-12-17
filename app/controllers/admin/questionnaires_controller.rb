class Admin::QuestionnairesController < Admin::ApplicationController
  def index

  end

  def new
    organization= Organization.find(params[:organization]);

    if organization.questionnaires.count>0
      @questionnaire=organization.questionnaires.first
    end
    if @questionnaire
      redirect_to edit_admin_questionnaire_path(@questionnaire) and return
    end
    @organization=organization;
    session[:organization]=organization.id;
    @questionnaire=organization.questionnaires.new
  end

  def create
    organization= Organization.find(session[:organization]);
    @questionnaire=organization.questionnaires.new
    @questionnaire.name="合作意向调查表"

    # if params[:service_population]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="service_population"
    answer.typename="checkbox"
    answer.answervalue=params[:service_population].to_s
    # end

    # if params[:service_population_display]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="service_population_display"
    answer.typename="display"
    answer.answervalue=params[:service_population_display].to_s
    # end

    # if params[:address_pro]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="address_pro"
    answer.typename="select"
    answer.answervalue=params[:address_pro].to_s
    # end
    # if params[:address_city]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="address_city"
    answer.typename="select"
    answer.answervalue=params[:address_city].to_s
    # end
    # if params[:address_county]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="address_county"
    answer.typename="select"
    answer.answervalue=params[:address_county].to_s
    # end

    # if params[:volunteer_from]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="volunteer_from"
    answer.typename="checkbox"
    answer.answervalue=params[:volunteer_from].to_s
    # end

    # if params[:volunteer_from_display]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="volunteer_from_display"
    answer.typename="text"
    answer.answervalue=params[:volunteer_from_display].to_s
    # end
    # if params[:p_counts]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="p_counts"
    answer.typename="radio"
    answer.answervalue=params[:p_counts].to_s
    # end

    # if params[:founds_source]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="founds_source"
    answer.typename="radio"
    answer.answervalue=params[:founds_source].to_s
    # end
    # if params[:p_counts]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="p_counts"
    answer.typename="checkbox"
    answer.answervalue=params[:p_counts].to_s
    # end

    # if params[:ismy]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="ismy"
    answer.typename="radio"
    answer.answervalue=params[:ismy].to_s
    # end

    # if params[:ismy_display]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="ismy_display"
    answer.typename="text"
    answer.answervalue=params[:ismy_display].to_s
    # end

    # if params[:agent]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="agent"
    answer.typename="radio"
    answer.answervalue=params[:agent].to_s
    # end
    # if params[:cooperation]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="cooperation"
    answer.typename="radio"
    answer.answervalue=params[:cooperation].to_s
    # end

    # if params[:suggestion]
    answer=@questionnaire.questionnaire_answers.new
    answer.keyname="suggestion"
    answer.typename="text"
    answer.answervalue=params[:suggestion].to_s
    # end


    if @questionnaire.save
      redirect_to edit_admin_organization_path(@questionnaire.organization_id), flash: {success: "调查问卷添加成功"}
    end
  end

  def edit
    @questionnaire=Questionnaire.find(params[:id])

  end


  def update
    @questionnaire=Questionnaire.find(params[:id])
    Questionnaire.transaction do


      @questionnaire.questionnaire_answers.each do |answer|
        if answer.keyname=="service_population"
          answer.answervalue=params[:service_population].to_s
        elsif answer.keyname=="service_population_display"
          answer.answervalue=params[:service_population_display].to_s
        elsif answer.keyname=="address_pro"
          answer.answervalue=params[:address_pro].to_s
          logger.debug answer.answervalue
        elsif answer.keyname=="address_city"
          answer.answervalue=params[:address_city].to_s
        elsif answer.keyname=="address_county"
          answer.answervalue=params[:address_county].to_s
        elsif answer.keyname=="volunteer_from"
          answer.answervalue=params[:volunteer_from].to_s
        elsif answer.keyname=="volunteer_from_display"
          answer.answervalue=params[:volunteer_from_display].to_s
        elsif answer.keyname=="p_counts"
          answer.answervalue=params[:p_counts].to_s
        elsif answer.keyname=="ismy"
          answer.answervalue=params[:ismy].to_s
        elsif answer.keyname=="founds_source"
          answer.answervalue=params[:founds_source].to_s
        elsif answer.keyname=="ismy_display"
          answer.answervalue=params[:ismy_display].to_s
        elsif answer.keyname=="agent"
          answer.answervalue=params[:agent].to_s
        elsif answer.keyname=="cooperation"
          answer.answervalue=params[:cooperation].to_s
        elsif answer.keyname=="suggestion"
          answer.answervalue=params[:suggestion].to_s
        end
        answer.save
      end
      if @questionnaire.save
        redirect_to edit_admin_organization_path(@questionnaire.organization_id), flash: {success: "调查问卷修改成功"}
      end
    end
  end
  # def get_check_items(key)
  #   q=@questionnaire.questionnaire_answers.where(:key=>key).first
  #   return false
  # end
end
