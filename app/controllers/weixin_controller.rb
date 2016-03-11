class WeixinController < ApplicationController
  
  skip_before_filter :verify_authenticity_token, :only => [:notify, :native_callback]
  
  def menu
    
    $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
   
    menu = {
      button: [
        {
            name: "守护绿色",
            sub_button: [
                {
                    type: "view",
                    name: "昕耕工坊",
                    url: "http://www.11haoonline.com/checkout/xgst"
                },
                {
                    type: "view",
                    name: "爱芬环保",
                    url: "http://www.11haoonline.com/checkout/lovehb"
                },
                {
                    type: "view",
                    name: "绿洲读书会",
                    url: "http://www.11haoonline.com/checkout/lzds"
                }
            ]
          # name: "筹款活动",
          # sub_button: [
          #   {
          #     type: "view",
          #     name: "紧急救助大山枣农",
          #     url: "http://www.11haoonline.com/jjjzdszn-ctryjhhtz-ytdjym"
          #   },
          #   {
          #     type: "view",
          #     name: "太阳花盛放",
          #     url: "http://www.11haoonline.com/tyhsf"
          #   },
          #   {
          #     type: "view",
          #     name: "威爱有你",
          #     url: "http://www.11haoonline.com/love-have-you"
          #   },
          #   {
          #     type: "view",
          #     name: "“特”立同行",
          #     url: "http://www.11haoonline.com/TLTX"
          #   }
          # ]
        },
        # {
        #   name: "拯救世界",
        #   sub_button: [
        #     {
        #       type: "view",
        #       name: "排行榜",
        #       url: "http://www.11haoonline.com/1rmb/ranking"
        #     },
        #     {
        #       type: "view",
        #       name: "我的影响力",
        #       url: "http://www.11haoonline.com/personal_story_campagin/my_influence"
        #     },
        #     {
        #       type: "view",
        #       name: "新年红包",
        #       url: "http://www.11haoonline.com/personal_story_campagin/get_red_pack"
        #     }
        #   ]
        # },
        {
          name: "我的11号",
          sub_button: [
            {
              type: "view",
              name: "我的订单",
              url: "http://www.11haoonline.com/user/order_list"
            },
            {
              type: "view",
              name: "我的筹款页面",
              url: "http://www.11haoonline.com/seller/campaign_list"
            }
          ]
        },
        {
          name: "关于我们",
          sub_button: [
            {
              type: "view",
              name: "11号计划",
              url: "http://mp.weixin.qq.com/s?__biz=MzAwOTAyNzk0NQ==&mid=206174662&idx=1&sn=2c8fb51a94197eae2a6817cc87235b76#rd"
            },
            {
              type: "view",
              name: "小伙伴招募",
              url: "http://mp.weixin.qq.com/s?__biz=MzAwOTAyNzk0NQ==&mid=200999358&idx=1&sn=f3f518181b1e0a13f03b840f23a4c316&scene=5#rd"
            },
            {
              type: "view",
              name: "关于我们",
              url: "http://mp.weixin.qq.com/s?__biz=MzAwOTAyNzk0NQ==&mid=200862140&idx=1&sn=e9eccc2a24d5868026b121381e8701a4&scene=5#rd"
            }
          ]
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
  
  def ajax_query_weixin_order
    
    app_id = ENV['WEIXIN_APPID']
    mch_id = ENV['WEIXIN_MCHID']
    out_trade_no = params[:out_trade_no]
    nonce_str = SecureRandom.uuid.tr('-', '')
    
    params_sign = {
      appid: app_id,
      mch_id:  mch_id,
      out_trade_no: out_trade_no,
      nonce_str: nonce_str
    }
    
    payload = WxPay::Service.make_payload(params_sign)
    
    r = RestClient::Request.execute(
      {
        method: :post,
        url: "https://api.mch.weixin.qq.com/pay/orderquery",
        payload: payload,
        headers: { content_type: 'application/xml' }
      }.merge(WxPay.extra_rest_client_options)
    )

    if r
      result = WxPay::Result.new Hash.from_xml(r)

      if result["return_code"] == 'SUCCESS'
        render text: result["trade_state"]
      else
        render text: result["return_msg"]
      end
      
    else
      render text: "error"
    end
    
  end
  
  def native_mode1
    
    puts "lalalalalalalalalalalalalalalalala22222222222"
    
    app_id = ENV['WEIXIN_APPID']
    mch_id = ENV['WEIXIN_MCHID']
    product_id = "1"
    timestamp = Time.now.getutc.to_i.to_s
    nonce_str = SecureRandom.uuid.tr('-', '')

    params_native_sign = {
      appid: app_id,
      mch_id: mch_id,
      time_stamp: timestamp,
      nonce_str: nonce_str,
      product_id: product_id
    }

    sign = WxPay::Sign.generate(params_native_sign)

    # test_url = "weixin://wxpay/bizpayurl?appid=wx2421b1c4370ec43b&mch_id=10000100&nonce_str=f6808210402125e30663234f94c87a8c&product_id=1&time_stamp=1415949957&sign=512F68131DD251DA4A45DA79CC7EFE9D"
    native_pay_url = "weixin://wxpay/bizpayurl?sign=" + sign + "&appid=" + app_id + "&mch_id=" + mch_id + "&product_id=" + product_id + "&time_stamp=" + timestamp + "&nonce_str=" + nonce_str
    puts native_pay_url
    require 'rqrcode_png'

    qr = RQRCode::QRCode.new( native_pay_url, :size => 14, :level => :h )
    @qr_url = qr.to_img.resize(250, 250).to_data_url
    # render text: @result
    
    render "native"
    
  end
  
  def native_mode2
    
    # render text: "aa"
     
    r = Random.new
    num = r.rand(1000...9999)
    @out_trade_no = DateTime.now.strftime("%Y%m%d%H%M%S") + num.to_s

    @result = "not wexin browser"
    @notify_url = root_url + 'weixin_custom/notify'

    params = {
      body: '11号公益圈订单',
      out_trade_no: @out_trade_no,
      total_fee: 1,
      spbill_create_ip: '127.0.0.1',
      notify_url: @notify_url,
      trade_type: 'NATIVE' # could be "JSAPI" or "NATIVE",
    }

    r = WxPay::Service.invoke_unifiedorder params
    @result = r.to_s
    @weixin_init_success = false
    @qr_url = "#"

    if r["return_code"] == 'SUCCESS' && r["result_code"] == 'SUCCESS'

      puts r["code_url"]
      puts root_url + 'weixin_custom/notify'
      r = WxPay::Service.invoke_unifiedorder params
      # qrcode_png = RQRCode::QRCode.new( r["code_url"], :size => 5, :level => :h ).to_img.resize(200, 200).save("public/uploads/qrcode/#{Time.now.to_i.to_s}.png")
#       @qr_url = "/uploads/qrcode/#{Time.now.to_i.to_s}.png"

      qr = RQRCode::QRCode.new( r["code_url"], :size => 5, :level => :h )
      @qr_url = qr.to_img.resize(300, 300).to_data_url

    end
    
    render "native"
    
  end
  
  def notify
    
    # order = Order.find_by_id(8)
    # order.fullname = "nononono"
    # order.save
    logger.info "hahahahahahahahahahahahahahahaha"

    result = Hash.from_xml(request.body.read)["xml"]

    if WxPay::Sign.verify?(result)
      
      logger.info "hahahahahahahahahahahahahahahaha"
      logger.info result.to_s
      
      # find your order and process the post-paid logic.

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)

    else
      
      render :xml => {return_code: "SUCCESS", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
      
    end
    
  end
  
  # def notify_alert
  #
  #   result = Hash.from_xml(request.body.read)["xml"]
  #
  #   session[:notify] =  result.to_s
  #   redirect_to root_url
  #
  #   if WxPay::Sign.verify?(result)
  #
  #     # find your order and process the post-paid logic.
  #
  #     render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
  #   else
  #     render :xml => {return_code: "SUCCESS", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
  #   end
  #
  # end
  
  def send_template
    
    touser = "oaR9aswmRKvGhMdb6kJCgIFKBpeg"
    template_id = "EnyULkSzskM-dYaof4tAGvueGVjkglhNfObOVdKWsgk"
    url = ""
    topcolor = "#FF0000"
    data = {
      first: {
        value:"您的订单已经提交成功！\n感谢您支持筹款团队：“特”立同行, 您本次购买的商品为上海体育学院特奥团助力。\n简单公益，只因有你。\n",
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
  
  def video
    
    yesterday = Time.now - 5.day
    puts Time.now
    puts yesterday
    # puts yesterday.beginning_of_day
#     puts yesterday.end_of_day
    
    # products = Product.where(["created_at >= ?", yesterday])
    # puts products.count

    orders = Order.completed.where(["campaign_id= ? and created_at >= ?", 5, yesterday])
    puts orders.count

    render text: "aa"
  
  end
    
  def video_post
    
      # result = Seller.find_by_sql("select * from sellers limit 5")
      # puts result.to_s
    
      # result2 = ActiveRecord::Base.connection.execute("select * from sellers limit 5")
      # puts result2.values
      #
      # render text: "aa"
  end
  
  def send_message
    
    to_user = "oaR9aswmRKvGhMdb6kJCgIFKBpeg"
    $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    
    # articles = [
    #   {
    #     title: "视频上传成功！",
    #     description: "点击创建seller。",
    #     url: "http://www.baidu.com"
    #   }
    # ]

    articles = [
      {
        title: "11号公益圈粉丝专享福利",
        url: "http://evt.dianping.com/event/mmbonus/new/newlanding.html?source=gongyi",
        picurl: "http://11haoonline.com/images/hongbao.jpg"
      }
    ]
    
    # @campaign = Campaign.friendly.find("test1")
#
#
#     articles = [
#       {
#         title: "您的筹款页面已经创建成功！",
#         description: "点击查看并分享。",
#         url: "http://www.11haoonline.com" + short_campaign_path(@campaign, seller: "12345"),
#         picurl: @campaign.logo
#       }
#     ]

    response = $wechat_client.send_news_custom(to_user, articles)
    
    render text: response.result.to_s
    
  end
  
  def test_cache
    
    require 'uri'
    require 'net/http'

    url = URI.encode("http://a.apix.cn/apixlife/express/delivery?id=710093138324&logistics=圆通速递")
    url2 = URI.parse(url)
    # puts url
    # url2 = URI(url)

    http = Net::HTTP.new(url2.host, url2.port)

    request = Net::HTTP::Get.new(url)
    request["accept"] = 'application/json'
    request["content-type"] = 'application/json'
    request["apix-key"] = 'e2fa6ac82e8e496c52e0f798d1aab5cf'

    response = http.request(request)
    
    # URI.encode(response.body)
#
#     data = ActiveSupport::JSON.decode(response.body.to_json)
#     puts data
    render text: URI.decode(response.body)
    
    # weixin_user_info = WeixinUserInfo.new
#     weixin_user_info.campaign_slug = "111"
#     weixin_user_info.video_url = "2222"
#
#     puts weixin_user_info.campaign_slug
#     puts weixin_user_info.video_url
#
#     WeixinCache.set("openid_1", weixin_user_info)
#
#     weixin_user_info2 = WeixinCache.get("openid_1")
#     puts weixin_user_info2.campaign_slug
#     puts weixin_user_info2.video_url
#
#     weixin_user_info2.campaign_slug = "333"
#     weixin_user_info2.video_url = "444"
#     WeixinCache.set("openid_1", weixin_user_info2)
#
#     weixin_user_info3 = WeixinCache.get("openid_1")
#     puts weixin_user_info3.campaign_slug
#     puts weixin_user_info3.video_url
    
#
#     weixin_info3 = WeixinCache.get("openid_2")
#
#     if weixin_info2
#
#       puts "aaaaa"
#     else
#       puts "bbbb"
#     end
#
#     if weixin_info3
#
#       puts "aaaaa"
#     else
#       puts "bbbb"
#     end
#
#     # WeixinCache.clear()
#
#     weixin_info4 = WeixinCache.get("openid_1")
#
#     if weixin_info4
#
#       puts "aaaaa"
#     else
#       puts "bbbb"
#     end
    
    # puts WeixinCache.get()
    
  end
  
  def download_file
    
    # uri = 'http://www.zhongchou.com/attachment/201505/13/15/0a512c396e06b271ec346d0598984ff135.jpg'

    $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    uri = $wechat_client.download_media_url("noSs9By0dV9PKzMjOX1Xf_eOYYDGPX2TSL5Jfpa-E_ARPKEhjzms_OwGG9ElBuxh")
    puts uri

    file_name = "video_" + DateTime.now.strftime("%Y%m%d%H%M%S") + ".mp4"
    require 'open-uri'

    open('./public/videos/' + file_name, 'wb') do |file|
      file << open(uri).read
    end

    render text: "aaaaa"
      
  end
  
end
