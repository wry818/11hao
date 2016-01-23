class PersonalStoryCampaginController < ApplicationController
  layout "story"
  def index
    # if is_wechat_browser?
    #
    #   weixin_get_user_info()
    #   @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
    #   weixin_address_init()
    #
    # end
  end

  def index_red_pack

  end
  # ajax_supporters
  def supporters

    render partial: "supporters"
  end

  def weixin_get_user_info()

    @nickname = ""
    @avatar_url = ""

    if session[:openid] && session[:access_token]

      $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
      user_info = $wechat_client.get_oauth_userinfo(session[:openid], session[:access_token])

      if user_info.result["errcode"] != "40003"
        @nickname = user_info.result["nickname"]
        @avatar_url = user_info.result["headimgurl"]
      end

      @sign_package = $wechat_client.get_jssign_package(request.original_url)

    end

  end

  def weixin_address_init()

    if session[:access_token]

      @app_id = ENV["WEIXIN_APPID"]
      @timestamp = ""
      @nonceStr = ""
      @addrSign = ""

      @timestamp = Time.now.getutc.to_i.to_s
      @nonceStr = SecureRandom.uuid.tr('-', '')
      @absolute_url = request.original_url

      sign = "accesstoken=" + session[:access_token].to_s + "&appid=" + @app_id.to_s + "&noncestr=" + @nonceStr.to_s + "&timestamp=" + @timestamp.to_s + "&url=" + @absolute_url.to_s

      require 'digest/sha1'
      @addrSign = Digest::SHA1.hexdigest(sign)

    end

  end
end
