# required
# WxPay.appid = 'wxc2251da36f59ced4'
# WxPay.key = '7KcRATv1Ino3mdopKaPGQQ7TtkNySuAm'
WxPay.appid = ENV["WEIXIN_APPID"]
WxPay.key = ENV["WEIXIN_APP_SECRET"]
WxPay.mch_id = ENV["WEIXIN_MCHID"]

# # optional - configurations for RestClient timeout, etc.
# WxPay.extra_rest_client_options = {timeout: 2, open_timeout: 3}