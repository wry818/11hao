class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    before_filter :set_defaults
    after_filter :store_location

    def store_location
      if !request.fullpath.start_with?("/users/") && !request.fullpath.start_with?("/auth/") && !request.xhr?
        session["user_return_to"]=request.fullpath
      end
    end

    def admin_user?
        current_user && current_user.admin?
    end

    def sales_user?
        current_user && current_user.is_sales?
    end
    
    def crs_user?
        current_user && current_user.is_crs?
    end
    
    private

    def set_defaults
        @fb = {
            title: 'Raisy',
            description: "Fun, easy online fundraisers for your school, team, charity, or group",
            image: Rails.configuration.default_facebook_image,
            url: root_url
        }
    end

    def authenticate_admin!
        redirect_to root_url and return unless admin_user?
    end

    def after_sign_in_path_for(resource)
      referer=stored_location_for(resource) || request.referer
      redirect_to_default=false
      
      if referer.nil?
        redirect_to_default=true
      else
        uri=URI.parse(referer)
        
        if uri.path=="" || uri.path=="/" || referer==request.url
          redirect_to_default=true
        else
          redirect_to_default=false
        end
      end
      
      if redirect_to_default
        if admin_user?
          admin_root_path
        else
          if sales_user? || crs_user?
            dashboard_campaigns_path + "?cp=no"
          else
            if current_user.is_chairperson?
              dashboard_campaigns_path
            else
              if current_user.any_seller?
                seller_dashboard_path
              else
                root_path
              end
            end
          end
        end
      else
        referer
      end
    end
end
