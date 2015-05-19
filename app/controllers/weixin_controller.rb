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
          name: "测试页面支付",
          url: $client.authorize_url(root_url + "weixin_custom/test")
        },
        {
          type: "view",
          name: "实际页面支付",
          url: $client.authorize_url(root_url)
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
    
    r = Random.new
    num = r.rand(1000...9999)
    out_trade_no = DateTime.now.strftime("%Y%m%d%H%M%S") + num.to_s
    
    @result = "not wexin browser"
    
    if session[:openid]

      params = {
        body: '11号公益圈订单',
        out_trade_no: out_trade_no,
        total_fee: 1,
        spbill_create_ip: '127.0.0.1',
        notify_url: root_url + 'weixin_custom/notify',
        trade_type: 'JSAPI', # could be "JSAPI" or "NATIVE",
        # openid: 'oaR9aswmRKvGhMdb6kJCgIFKBpeg' # required when trade_type is `JSAPI`
        # openid: 'oaR9as940svyxuTEuKZgeibjC7ng'
        openid: session[:openid]
      }

      r = WxPay::Service.invoke_unifiedorder params
      @result = r.to_s
      @weixin_init_success = false
      
      if r["return_code"] == 'SUCCESS' && r["result_code"] == 'SUCCESS'

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

      end

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
  
  def address
    
    @campaign_id = session[:campaign_id]
    @timestamp = ""
    @nonceStr = ""
    @addrSign = ""
    @app_id = ENV["WEIXIN_APPID"]
    @token = ""
    
    code = params[:code]
    state = params[:state]
    
    @code = code
    @state = state
    
    require 'net/http'

    @response_code = 0
    @message = ""

    uri = URI("https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + ENV["WEIXIN_APPID"] + "&secret=" + ENV["WEIXIN_APP_SECRET"] + "&code=" + code + "&grant_type=authorization_code")

    Net::HTTP.start(uri.host, uri.port,
      :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      response = http.request(request)
      response_code = Integer(response.code)
      
      @response_code = response.code
      @message = response.body
      
      @json = JSON.parse(response.body)
      
      @token = @json["access_token"]
      
    end
    
    render text: response.body
    
    # @timestamp = Time.now.getutc.to_i.to_s
#     @nonceStr = SecureRandom.uuid.tr('-', '')
#     @absolute_url = request.original_url
#
#     sign = "accesstoken=" + @token + "&appid=" + @app_id + "&noncestr=" + @nonceStr + "&timestamp=" + @timestamp + "&url=" + @absolute_url;
#     @aa =  sign
#
#     require 'digest/sha1'
#     # @addrSign = Digest::SHA1.hexdigest([@token, @app_id, @nonceStr, @timestamp ,@absolute_url].sort.join)
#     @addrSign = Digest::SHA1.hexdigest(sign)
    
  end
  
end
