class PersonalStoryController < ApplicationController

  layout "story"
  
  def index
    @campaign = Campaign.find_by_slug("support-lanlan")
    @is_wechat_browser = is_wechat_browser?
    @progress_percent = @campaign.progress_percent
    
    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      # weixin_payment_init(@order)
      weixin_address_init()
      
    end
    
    load_supporters
  end
  
  def supporters
    @campaign = Campaign.find_by_slug("support-lanlan")
    
    load_supporters
    
    render partial: "supporters" and return
  end

  def checkout_confirmation
    @campaign=Campaign.find_by_slug("support-lanlan")
    @order=@campaign.orders.new
    
    donation=params[:direct_donation].to_f * 100
    
    if donation<=0
      redirect_to personal_story_index_path, flash: { danger:"请输入正确的金额" } and return
    end

    @order.direct_donation=donation
    @order.save
    
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
    @campaign=Campaign.find_by_slug("support-lanlan")
    @order=@campaign.orders.new
    
    donation=params[:direct_donation].to_f * 100
    
    if donation<=0
      redirect_to personal_story_index_path, flash: { danger:"请输入正确的金额" } and return
    end
    
    @order.direct_donation=donation
    @order.save
    
    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to personal_story_index_path, flash: { danger: message[0...-2] } and return
    end
    session[:order_id]=@order.id

    render partial: "weixin_onBridgeReady" and return
  end
  
  def show_confirmation

    if session[:confirm_order_id]
      @order = Order.find_by_id(session[:confirm_order_id])
      @campaign=Campaign.find_by_slug("support-lanlan")
      
      if @order.campaign.used_as_default?
        @order.campaign_id = @campaign.id
        @order.save
      end

      unless @order && @order.completed? && @order.valid_order?
        redirect_to(personal_story_index_path, flash: { warning: "捐款失败请刷新后重试" }) and return
      end
    else
      redirect_to(personal_story_index_path, flash: { warning: "捐款失败请刷新后重试" }) and return
    end

    render "checkout_confirmation" and return
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
  
  private
  
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
