namespace :eleven do
  task :test => :environment do
    campaign_id = Rails.env.test? ? 18 : 65
    
    puts campaign_id
    
    orders = Order.completed.where(:campaign_id=>campaign_id).where("seller_id is null")
    
    orders.each do |order|
      puts order.id
      
      params_sign = {
        appid: "wxc2251da36f59ced4",
        mch_id:  "10019709",
        out_trade_no: order.out_trade_no || "",
        nonce_str: SecureRandom.uuid.tr('-', '')
      }

      p = WxPay::Service.make_payload(params_sign)

      x = RestClient::Request.execute(
        {
          method: :post,
          url: "https://api.mch.weixin.qq.com/pay/orderquery",
          payload: p,
          headers: { content_type: 'application/xml' }
        }.merge(WxPay.extra_rest_client_options)
      )

      if x
        r = WxPay::Result.new Hash.from_xml x

        if r["return_code"] == 'SUCCESS' && r["result_code"] == "SUCCESS"
          order.seller_id = (r["trade_state"] == 'SUCCESS' ? 1 : 0)
          order.save
        end
      end
    end
  end
end