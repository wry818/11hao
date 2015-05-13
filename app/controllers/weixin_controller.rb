
# require "digest/sha1"  
class WeixinController < ApplicationController
  
  # @@token = "echarity"
  # def index
#
#     wechat_button_yml = load_yml_file "weixin_menu.yml"
#     post_hash = wechat_button_yml['menu']
#
#     puts "aaaa"
#     access_token = get_access_token()
#     puts "bbbbb"
#     puts access_token
#
#     create_menu()
#
#     if check_signature?(params[:signature],params[:timestamp],params[:nonce])
#          return render text: params[:echostr]
#          # {text: params[:echostr], status: 200, valid: true}
#     end
#
#     return render text: "fail"
#
#   end
#
#   def reply
#
#     if check_signature?(params[:signature], params[:timestamp], params[:nonce]) #验证消息真实性
#
#       if params[:xml][:MsgType] == "event"
#
#         if params[:xml][:Event] == "subscribe"
#           render "wechat/info", layout: false, :formats => :xml          #关注
#         end
#
#       else
#         render "wechat/info", layout: false, :formats => :xml  #用户输入消息时，回送欢迎关注
#       end
#
#    end
#
#   end
  
  def menu
    
    $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    # puts $client.is_valid?
    
    # redirect_uri = "http://"
    # redirect_uri = ERB::Util.url_encode(redirect_uri)
    #
    # puts redirect_uri
#     url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=" + ENV["WEIXIN_APPID"] + "&redirect_uri=" + redirect_uri + "&response_type=code&scope=snsapi_base&state=weixin#wechat_redirect"

    menu = {
      button: [
        {
          type: "view",
          name: "zhifu",
          url: $client.authorize_url(root_url + "weixin_custom/test")
        }
      ]
    }.to_json

    # puts menu

     response = $client.create_menu(menu) # Hash or Json
     # response = $client.menu
     # response = $client.delete_menu
     
      # redirect_url = "http://77a5dc7b.ngrok.io/index/authorize"
      # aa = $client.authorize_url("http://77a5dc7b.ngrok.io/index/authorize")
      # puts aa
      
      # # 回调后，获取code请求token或者openid:
#       sns_info = $client.get_oauth_access_token(params[:code])
#       # 再调用以下API，拉取用户信息：
#       $client.get_oauth_userinfo(openid, oauth_token)
      
      render text: response.result
    
  end
  
  def authorize
    
    render text: session[:openid]
          
  end
  
  # private
  #
  #   def check_signature?(signature,timestamp,nonce)
  #     Digest::SHA1.hexdigest([timestamp,nonce,@@token].sort.join) == signature
  #   end
  #
  #   def get_access_token
  #
  #     response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=" + ENV['WEIXIN_APPID'] + "&secret=" + ENV['WEIXIN_APP_SECRET'])
  #     response_json = JSON.parse(response.options[:response_body])
  #     response_json["access_token"]
  #
  #   end
  #
  #   def create_menu
  #
  #     puts "aaaa"
  #     access_token = get_access_token()
  #     puts "bbbbb"
  #     puts access_token
  #
  #     post_url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=" + access_token
  #
  #     wechat_button_yml = load_yml_file "weixin_menu.yml"
  #     post_hash = wechat_button_yml['menu']
  #
  #     Typhoeus::Request.post(post_url, body: generate_post_hash(post_hash))
  #
  #   end
  #
  #   def load_yml_file file_name
  #     yml_name = Rails.root.join(Rails.root, "./config/", file_name)
  #     YAML.load_file(yml_name)
  #   end
  #
  #   #处理菜单中文问题
  #   def generate_post_hash post_hash
  #     post_hash.to_json.gsub!(/\\u([0-9a-z]{4})/) { |s| [$1.to_i(16)].pack("U") }
  #   end
    
    
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
