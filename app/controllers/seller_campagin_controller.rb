class SellerCampaginController < ApplicationController

  layout "seller"

  def index

    @campaigns=Campaign.where(:fundraising_event_id=>1)
    ids=""

    @campaigns.each do |i|
      ids+=i.id.to_s+","
    end

    @current_rank = 0
    ids=ids.chop
    logger.debug ids


    # ladder today
    query = QueryHelper.get_ladder_campaign(ids,"")
    @seller_ladder_result = ActiveRecord::Base.connection.execute(query)

    if @seller_ladder_result&&@seller_ladder_result.count>0
      @seller_today_first=@seller_ladder_result[0]
      @campaign_first=Campaign.find(@seller_today_first["id"])
    end

    query = QueryHelper.get_ladder_campaign(ids,DateTime.now.to_date.to_s)
    @seller_ladder_today_result = ActiveRecord::Base.connection.execute(query)

    if @seller_ladder_today_result&&@seller_ladder_today_result.count>0
      @seller_today_top=@seller_ladder_today_result[0]
      @campaign_top=Campaign.find(@seller_today_top["id"])
    end




    # if !@campaign_top
    #   if @seller_ladder_result&&@seller_ladder_result.count>0
    #     @seller_today_top=@seller_ladder_result[0]
    #     @campaign_top=Campaign.find(@seller_today_top["id"])
    #   end
    # end

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()
    end
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
