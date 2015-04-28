class WeixinController < ApplicationController

  def test

    params = {
      body: '测试商品22',
      out_trade_no: 'test004',
      total_fee: 1,
      spbill_create_ip: '127.0.0.1',
      notify_url: 'http://10.12.0.182:3000/weixin/notify',
      trade_type: 'JSAPI', # could be "JSAPI" or "NATIVE",
      # openid: 'oaR9aswmRKvGhMdb6kJCgIFKBpeg' # required when trade_type is `JSAPI`
      openid: 'oaR9as940svyxuTEuKZgeibjC7ng'
    }

    r = WxPay::Service.invoke_unifiedorder params
    puts r
#     puts r["appid"]
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
    puts @js_pay_sign
  
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
