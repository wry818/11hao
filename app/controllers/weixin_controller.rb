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
        }
        # {
        #   type: "view",
        #   name: "测试页面支付",
        #   url: $client.authorize_url(root_url + "weixin_custom/test")
        # },
        # {
#           type: "view",
#           name: "实际页面支付",
#           url: $client.authorize_url(root_url)
#         }
# {
#   type: "view",
#   name: "支付通知",
#   url: root_url + 'weixin_custom/notify2'
# }
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
    puts root_url + 'weixin_custom/notify'
    
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
    
      # $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
#       $client.send_text_custom(session[:openid], "支付成功！11号公益圈感谢您的支持！")
      # find your order and process the post-paid logic.

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      
    
      # $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
#       $client.send_text_custom(session[:openid], "支付成功！11号公益圈感谢您的支持！")
      
      render :xml => {return_code: "SUCCESS", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
    
    
  end
  
  def notify2
    
    $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    $client.send_text_custom('oaR9aswmRKvGhMdb6kJCgIFKBpeg', "支付成功！订单编号11号公益圈感谢您的支持！")
    
  end
  
  def notify_alert
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
    
    
    
    @timestamp = Time.now.getutc.to_i.to_s
    @nonceStr = SecureRandom.uuid.tr('-', '')
    @absolute_url = request.original_url

# render text: "@timestamp: " + @timestamp + "@nonceStr: " + @nonceStr.to_s  + "@@token: " + @absolute_url.to_s

    sign = "accesstoken=" + @token.to_s + "&appid=" + @app_id.to_s + "&noncestr=" + @nonceStr.to_s + "&timestamp=" + @timestamp.to_s + "&url=" + @absolute_url.to_s
    # @aa =  sign

    require 'digest/sha1'
    # @addrSign = Digest::SHA1.hexdigest([@token, @app_id, @nonceStr, @timestamp ,@absolute_url].sort.join)
    @addrSign = Digest::SHA1.hexdigest(sign)
    
  end
  
  def send_template
    
    touser = "oaR9aswmRKvGhMdb6kJCgIFKBpeg"
    template_id = "EnyULkSzskM-dYaof4tAGvueGVjkglhNfObOVdKWsgk"
    url = ""
    topcolor = "#FF0000"
    data = {
      first: {
        value:"您的订单已经提交成功！\n感谢您支持筹款团队：“特”立同行, 您本次购买的商品为上海体育学院特奥团助力。\n简单公益，只因有你。",
        color:"#000000"
      },
      keyword1: {
        value:"00000138",
        color:"#000000"
      },
      keyword2: {
        value:"2015年5月21日 10:58",
        color:"#000000"
      },
      keyword3: {
        value:"58元",
        color:"#000000"
      },
      keyword4: {
        value:"微信支付",
        color:"#000000"
      },
      remark: {
        value:"",
        color:"#000000"
      }
    }
    
    $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    response = $client.send_template_msg(touser, template_id, url, topcolor, data)
    
    render text: response.result.to_s
    
  end
  
end
