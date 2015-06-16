class WeixinHelper
  
  def self.get_user_info(openid, access_token)
    
    logger.info "dddddddddd"
    
    if openid && access_token
      
      $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
      user_info = $wechat_client.get_oauth_userinfo(openid, access_token)
      
      if user_info.result["errcode"] != "40003"
          
          logger.info "cccccccccccc"
          user_info
      else
          nil
      end
    
    else
      
      nil
      
    end
    
  end
  
end