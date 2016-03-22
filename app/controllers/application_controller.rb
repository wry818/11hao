class ApplicationController < ActionController::Base
    before_action :get_wechat_sns, if: :is_wechat_browser?
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    before_filter :set_defaults
    after_filter :store_location
    
    # error page set
    AR_ERROR_CLASSES = [ActiveRecord::RecordNotFound, ActiveRecord::StatementInvalid]
    ERROR_CLASSES = [NameError, NoMethodError, RuntimeError,
                     ActionView::TemplateError,
                     ActiveRecord::StaleObjectError, ActionController::RoutingError,
                     ActionController::UnknownController, AbstractController::ActionNotFound,
                     ActionController::MethodNotAllowed, ActionController::InvalidAuthenticityToken]

    ACCESS_DENIED_CLASSES = [CanCan::AccessDenied]
    if Rails.configuration.error_page_ishow
      rescue_from *AR_ERROR_CLASSES, :with => :page_error
      rescue_from *ERROR_CLASSES, :with => :page_error
      rescue_from *ACCESS_DENIED_CLASSES, :with => :page_error
    end
    # @@my_log = Logger.new("#{Rails.root}/log/mydev.log")
    def page_error
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/500", :layout => false, :status => :not_found }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end
    def page_not_found
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end

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
    
    def is_wechat_browser?

      request.env["HTTP_USER_AGENT"].include? "MicroMessenger"
      # $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
      # url = $wechat_client.authorize_url(request.original_url)
      # puts url

    end
    
    def is_wechat_browser2
        true
    end
    
    def get_wechat_sns
      need_auth = false
      
      if session[:openid].blank?
        if Rails.env.test? && params[:openid].present?
          session[:openid] = params[:openid]
          session[:access_token] = params[:access_token]

          return
        end

        if params[:code].present?
          $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
          sns_info = $wechat_client.get_oauth_access_token(params[:code])

          if sns_info.result["openid"] && sns_info.result["access_token"] && sns_info.result["errcode"] != "40029"
              session[:openid] = sns_info.result["openid"]
              session[:access_token] = sns_info.result["access_token"]
              session[:expires_in] = sns_info.result["expires_in"]
  
              if params[:is_test]
          
                param_url = ""
                request.query_parameters.each do |key, value|
                  param_url += "&" + "#{key}=" + "#{value}"
                end
          
                # logger.info "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                # logger.info param_url
    
                url = "http://test.11haoonline.com" + request.path + "?openid=" + sns_info.result["openid"] + "&access_token=" + sns_info.result["access_token"] + param_url
    
                redirect_to url and return
              end
          else
              need_auth = true
          end
        else
          need_auth = true
        end

        if need_auth
          redirect_uri = ERB::Util.url_encode(request.original_url)

          if Rails.env.test?
            if request.path == "/"
              redirect_uri = "http://www.11haoonline.com?is_test=1"
            else
              redirect_uri = "http://www.11haoonline.com" + request.path + "?is_test=1"  
            end
      
            param_url = ""
            request.query_parameters.each do |key, value|
              param_url += "&" + "#{key}=" + "#{value}"
            end

            # logger.info "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
            # logger.info param_url
            redirect_uri = redirect_uri + param_url
            # logger.info redirect_uri
          else
            # In case callback url contains code which will trigger re-auth
            redirect_uri = ERB::Util.url_encode(request.original_url.gsub(/code=/, "_code="))
          end
          # logger.info redirect_uri
          url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + ENV["WEIXIN_APPID"] + "&redirect_uri=" + redirect_uri + "&response_type=code&scope=snsapi_userinfo&state=weixin#wechat_redirect"

          redirect_to url and return
        end
      else
        if params[:is_test]
    
          param_url = ""
          request.query_parameters.each do |key, value|
            param_url += "&" + "#{key}=" + "#{value}"
          end
    
          # logger.info "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
          # logger.info param_url
    
          url = "http://test.11haoonline.com" + request.path + "?openid=" + session[:openid] + "&access_token=" + session[:access_token] + param_url
          # logger.info url
          redirect_to url and return
        end
      end
      
    end
        
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
