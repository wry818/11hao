class ApplicationController < ActionController::Base
    before_action :get_wechat_sns, if: :is_wechat_brower?
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
    
    def is_wechat_brower?
        request.env["HTTP_USER_AGENT"].include? "MicroMessenger"
        # $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
#         url = $wechat_client.authorize_url(request.original_url)
#         puts url
    end
    
    def get_wechat_sns
      
      if session[:openid].blank?
        
        if params[:code].present?
          
          $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
          sns_info = $wechat_client.get_oauth_access_token(params[:code])
        
          Rails.logger.debug("Weixin oauth2 response: #{sns_info.result}")
        
          # 重复使用相同一个code调用时：
          if sns_info.result["errcode"] != "40029"
              session[:openid] = sns_info.result["openid"]
              session[:access_token] = sns_info.result["access_token"]
              session[:expires_in] = sns_info.result["expires_in"]
              session[:nickname] = sns_info.result["nickname"]
          end
          
        else
          
          # $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
#           url = $wechat_client.authorize_url(request.original_url)
#           redirect_to url
          
          redirect_uri = ERB::Util.url_encode(request.original_url)
          url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + ENV["WEIXIN_APPID"] + "&redirect_uri=" + redirect_uri + "&response_type=code&scope=snsapi_userinfo&state=weixin#wechat_redirect"
          redirect_to url
          
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
