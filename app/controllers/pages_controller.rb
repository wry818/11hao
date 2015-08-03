class PagesController < ApplicationController

    def index
      
      logger.info "aaaaaaaaaaaaa"
      puts "cccccccccccc"
      Rails.logger.debug("ssssssssssssss")
      
    end

    def search
        @register = params[:register] == "true" ? true : false
        @search = params[:search]
        @is_recent = false
        
        if params[:search].present?
          query = "title ILIKE :search OR organizations.name ILIKE :search 
            OR organizations.entertainment_customer_id ILIKE :search"
           
           @campaigns = Campaign.active.joins(:organization).where(query, search: "%"+@search+"%").order("title, organizations.name, campaigns.id desc").page(params[:page])
        else
          # If the search is not a part of seller registration, 
          # display 12 lastest created campaigns by default
          
          if !@register
            @is_recent = true
            @campaigns = Campaign.active.order(:id=>:desc).page(1)
          end
        end
        
        @show_popup = session[:search_camp_popup] || "yes"
    end

    def ajax_invite
        render text: 'failure' and return if params[:invite].blank?

        invite = Invite.new(invite_params)

        if invite.save
            # gb = Gibbon::API.new(ENV['MAILCHIMP_API_KEY'])
            # begin
            #     gb.lists.subscribe({ :id => ENV['MAILCHIMP_INVITE_LIST_ID'],
            #                                 :email => {:email => invite.email},
            #                                 :double_optin => false,
            #                                 :update_existing => true,
            #                                 :send_welcome => false })
            # rescue => exception
            #     logger.info "Error subscribing #{invite.email} to mailchimp: #{exception.message}"
            # end

            render text: 'success'
        else
            render text: 'failure'
        end

        begin
            AdminMailer.invite_notification(invite).deliver
        rescue => exception
            logger.info exception.message
        end

    end
    
    def ajax_search_camp_popup
        begin
          popup = params[:popup]
          
          if popup == "disable"
              session[:search_camp_popup] = "no"
          end
                  
          render text: session[:search_camp_popup] || "yes"
        rescue => exception
          logger.info exception.message
          render text: session[:search_camp_popup] || "yes"
        end
    end
    
    def tos
      render "tos", :layout=>false
    end
    
    def reg_tos
      render "reg_tos", :layout=>false
    end

    private

    def invite_params
        params.require(:invite).permit :name, :email, :organization, :collection_id, :source
    end

end
