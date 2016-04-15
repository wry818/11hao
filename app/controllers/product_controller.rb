class ProductController < ApplicationController
  layout "shop_weixin"
  def index
    if params[:id]

    elsif params[:ids]&&params[:ids].to_s.length>0
      params[:id]=params[:ids].split("_")[1]
    else
      params[:id]="default"
    end
    # session[:openid]="oaR9as9LCc7KFlh1dih3uXEy_5-w"
    # logger.debug session[:openid] +params[:id]
    if session[:openid]&&params[:id]=="list"
      # logger.debug session[:openid]
      order= Order.completed.where(:open_id =>session[:openid] ).order(:id=>:desc).first
      logger.debug order.campaign.end_date
      logger.debug DateTime.now
      if order&&((!order.campaign.end_date)||(order.campaign.end_date&&order.campaign.end_date>=DateTime.now))

        redirect_to(hotsale_index_path("hotsale_#{order.campaign.slug}")) and return
      else
        redirect_to(hotsale_index_path("hotsale_default")) and return
      end
    end
    @campaign=Campaign.find_by_slug(params[:id]);
    if !@campaign
      @campaign=Campaign.find_by_slug("default");
    end


    @products=Product.where(:is_hot_sale => :true).isnot_destroy.order(:updated_at=>:desc)
    @is_wechat_browser = is_wechat_browser?
    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end
  end
  def weixin_get_user_info()

    @nickname = ""
    @avatar_url = ""
    # logger.info "aaaaaaaaaaaaaaaaaaaaaaaaango"
    # logger.info  session[:openid]
    # logger.info  session[:access_token]
    if session[:nickname] && session[:avatarurl]
      @nickname = session[:nickname]
      @avatar_url = session[:avatarurl]
      # logger.info  @nickname
      # logger.info  @avatar_url
      # logger.info "aaaaaaaaaaaaaaaaaaaaaaaaasession"
    else
      if session[:openid] && session[:access_token]

        $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
        user_info = $wechat_client.get_oauth_userinfo(session[:openid], session[:access_token])

        if user_info.result["errcode"] != "40003"
          @nickname = user_info.result["nickname"]
          @avatar_url = user_info.result["headimgurl"]

          session[:nickname] = @nickname
          session[:avatarurl] = @avatar_url
        end
        logger.info  user_info
        logger.info "aaaaaaaaaaaaaaaaaaaaaaaaasession"
      end
    end

    if session[:openid] && session[:access_token]
      $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])

      @sign_package = $wechat_client.get_jssign_package(request.original_url)
    end

    @nickname
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
