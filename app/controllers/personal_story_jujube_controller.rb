class PersonalStoryJujubeController < ApplicationController
  layout "story"

  before_filter :manage_session_order, only: [:index]
  def index
    @is_wechat_browser = is_wechat_browser?
    @progress_percent = @campaign.progress_percent

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      # weixin_payment_init(@order)
      #weixin_address_init()

    end
    load_supporters
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
  def supporters
    load_supporters

    render partial: "supporters" and return
  end
  private
  def manage_session_order
    @campaign = Campaign.find_by_slug("jjjzdszn-ctryjhhtz-ytdjym")
    @product=@campaign.collection.products.first
    unless @order && @order.campaign_id == @campaign.id && @order.status == 0
      @order = Order.new
    end
  end

  def load_supporters
    @page = params[:page].to_i
    @page = 1 if @page == 0
    @show_pager = false
    @supporters = @campaign.orders.completed.select(
        "id,avatar_url,fullname,direct_donation").order(:id=>:desc).page(@page).per(10)

    if @supporters.total_pages > 0 && @supporters.total_pages > @page
      @show_pager = true

      query = "?" + {:page => @page + 1}.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")

      @page_url = personal_story_supporters_path + query
    end
  end
end
