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
  
  def weixin_payment_get_req
    
    logger.info "aaaaaaaaaaaaaaaaaaaaaa"
    
    donation_amount = params[:direct_donation]

    logger.info donation_amount
    weixin_payment_init(donation_amount)
    
    if @weixin_init_success
      render json: {appId: @js_app_id, 
        timeStamp: @js_timestamp, 
        nonceStr: @js_noncestr, 
        package: @package,
        signType: "MD5",
        paySign: @js_pay_sign}.to_json and return
    end
    
    render json: {appId: "", 
      timeStamp: "", 
      nonceStr: "", 
      package: "",
      signType: "MD5",
      paySign: ""}.to_json and return
      
  end
  
  def weixin_payment_init(donation_amount)
    
    logger.info "xxxxxxxxxxxxxxxxxxx"
    logger.info donation_amount
    
    donation_amount = donation_amount.to_i * 100
    logger.info donation_amount
    # session[:openid] = "oaR9aswmRKvGhMdb6kJCgIFKBpeg"
    
    if session[:openid]
      
      r = Random.new
      num = r.rand(1000...9999)
      out_trade_no = DateTime.now.strftime("%Y%m%d%H%M%S") + num.to_s #生产随机订单号，这里用当前时间加随机数，保证唯一
      
      params = {
        body: '11号公益圈订单',
        out_trade_no: out_trade_no,
        # total_fee: 1,
        total_fee: donation_amount,
        spbill_create_ip: '127.0.0.1',
        notify_url: root_url + 'checkout/weixin_notify',
        trade_type: 'JSAPI', # could be "JSAPI" or "NATIVE",
        # openid: 'oaR9aswmRKvGhMdb6kJCgIFKBpeg' # required when trade_type is `JSAPI`
        # openid: 'oaR9as940svyxuTEuKZgeibjC7ng'
        openid: session[:openid]
      }

      r = WxPay::Service.invoke_unifiedorder params
      
      @weixin_init_success = false
      
      logger.info r
      logger.info r["return_code"]
      
      if r["return_code"] == 'SUCCESS' && r["result_code"] == 'SUCCESS'

        @js_noncestr = SecureRandom.uuid.tr('-', '')
        @js_timestamp = Time.now.getutc.to_i.to_s
        @js_app_id = r["appid"]
        @package = "prepay_id=" + r["prepay_id"]

        params_pre_pay_js = {
          appId: @js_app_id,
          nonceStr: @js_noncestr,
          package: @package,
          timeStamp: @js_timestamp,
          signType: 'MD5'
        }

        @js_pay_sign = WxPay::Sign.generate(params_pre_pay_js)
        @weixin_init_success = true
        
      end

    end
    
  end
  
  def weixin_notify
    
    # logger.info "hahahahahahahahahahahahahahahaha"
    
    result = Hash.from_xml(request.body.read)["xml"]
    
    if WxPay::Sign.verify?(result)
      
      open_id = result["openid"]
      out_trade_no = result["out_trade_no"]
      logger.info out_trade_no
      
      order = Order.where(:out_trade_no => out_trade_no).first
      
      if order
        
        if open_id.present?
          order.open_id = open_id
        end
        
        order.status = 3
        order.save
        
      end
      
      # find your order and process the post-paid logic.
      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)

    else
      
      render :xml => {return_code: "SUCCESS", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
      
    end

  end
  
end
