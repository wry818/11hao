class WeixinController < ApplicationController
  
  def menu
    
    $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    # puts $client.is_valid?

    menu = {
      button: [
        {
          type: "view",
          name: "11号计划",
          url: "http://eqxiu.com/s/CWK4Qndj?eqrcode=1&from=singlemessage&isappinstalled=0"
        },
        {
          type: "view",
          name: "测试支付",
          url: $client.authorize_url(root_url + "weixin_custom/test")
        }
      ]
    }.to_json
    
    response = $client.create_menu(menu) # Hash or Json
    
    render text: response.result
    
  end
  
  def menulist
    
    $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    
    response = $client.menu
    
    render text: response.result
    
  end
  
  
  def authorize
    
    render text: session[:openid]
          
  end
    
  def test
    
    puts "aaaa"
    puts root_url
    if session[:openid]
      
      puts "bbbbb"
      params = {
        body: '11号公益圈订单',
        out_trade_no: 'test005',
        total_fee: 1,
        spbill_create_ip: '127.0.0.1',
        notify_url: root_url + 'weixin_custom/notify',
        trade_type: 'JSAPI', # could be "JSAPI" or "NATIVE",
        # openid: 'oaR9aswmRKvGhMdb6kJCgIFKBpeg' # required when trade_type is `JSAPI`
        # openid: 'oaR9as940svyxuTEuKZgeibjC7ng'
        openid: session[:openid]
      }

      r = WxPay::Service.invoke_unifiedorder params
      puts r

      @weixin_init_success = false
      if r["return_code"] == 'SUCCESS' && r["result_code"] == 'SUCCESS'

        puts "aa"
        @js_noncestr = SecureRandom.uuid.tr('-', '')
        @js_timestamp = Time.now.getutc.to_i.to_s
        @app_id = r["appid"]
        @package = "prepay_id=" + r["prepay_id"]

        params_pre_pay_js = {
          appId: @app_id,
          nonceStr: @js_noncestr,
          package: @package,
          timeStamp: @js_timestamp,
          signType: 'MD5'
        }

        @js_pay_sign = WxPay::Sign.generate(params_pre_pay_js)
        @weixin_init_success = true
        puts @js_pay_sign

      end
      
    else
      
      puts "ccccc"
      
    end

  end

  def notify
    result = Hash.from_xml(request.body.read)["xml"]

    if WxPay::Sign.verify?(result)

      # find your order and process the post-paid logic.

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "SUCCESS", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end

  end
  
end
