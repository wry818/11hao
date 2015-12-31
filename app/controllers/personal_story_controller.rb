class PersonalStoryController < ApplicationController

  layout "story"
  def index

    @campaign=Campaign.find_by_slug("support-lanlan");


    @is_wechat_browser = is_wechat_browser?
    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      # weixin_payment_init(@order)
      weixin_address_init()
      
    end
  end

  def checkout_confirmation
    @campaign=Campaign.find_by_slug("support-lanlan");
    @order=@campaign.orders.new

    @order.direct_donation=params[:direct_donation].to_f * 100
    @order.save
    if  @order.direct_donation<=0
      redirect_to personal_story_index_path, flash: { danger:"请输入正确的金额" } and return
    end
    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to personal_story_index_path, flash: { danger: message[0...-2] } and return
    end
    session[:order_id]=@order.id

    redirect_to(checkout_weixin_native_pay_url(@campaign)) and return
  end
  def checkout_confirmation_weixin
    @campaign=Campaign.find(1)
    @order=@campaign.orders.new

    @order.direct_donation=params[:direct_donation].to_f * 100
    @order.save
    if  @order.direct_donation<=0
      redirect_to personal_story_index_path, flash: { danger:"请输入正确的金额" } and return
    end
    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to personal_story_index_path, flash: { danger: message[0...-2] } and return
    end
    session[:order_id]=@order.id

    render partial: "weixin_onBridgeReady"
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
