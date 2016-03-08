class CampaignNgoController < ApplicationController
  layout "story_personal"
  before_filter :manage_session_order, only: [ :confirmation, :confirmation_weixin]
  def lzds

    campaign_slug = "1454297766"
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_lzds_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def lzds_supporters

    campaign_slug = "1454297766"
    path = campagin_ngo_lzds_supporters_path

    load_personal_story_campaign_supporter(campaign_slug, path)

  end

  def load_campaign_page(campaign_slug, path)

    @campaign = Campaign.find_by_slug(campaign_slug)
    @campaign_total_count = @campaign.orders.completed.count

    @is_wechat_browser = is_wechat_browser?

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end

    load_supporters(path)

  end
  def load_campaign_supporter(campaign_slug, path)

    @campaign = Campaign.find_by_slug(campaign_slug)

    load_supporters(path)

    render partial: "supporters" and return

  end



  def confirmation
    @order = @campaign.orders.new
    @order.direct_donation=1
    @order.save

    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to campagin_ngo_lzds_path, flash: {danger: message[0...-2]} and return
    end
    session[:order_id]=@order.id

    redirect_to(checkout_weixin_native_pay_url(@campaign)) and return
  end

  def confirmation_weixin

    # session[:openid] = "oaR9aswmRKvGhMdb6kJCgIFKBpeg1"
    # @order_count = @campaign.orders.completed.where(:open_id => session[:openid]).count
    # if @order_count >= 2
    #   render json: {order_id:"", error_msg:"您发的红包已超最大数量，请支持其他机构的小伙伴！"}.to_json and return
    # end

    @order = @campaign.orders.new

    if params[:seller_id]
      @seller = Seller.find_by_id(params[:seller_id])

      @order.seller_id=@seller.id if @seller
    end

    @order.direct_donation = params[:direct_donation].present? ? params[:direct_donation].to_i : 1
    @order.save

    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to campagin_ngo_lzds_path, flash: {danger: message[0...-2]} and return
    end

    session[:order_id]=@order.id
    session[:confirm_order_id]

    render json: {order_id:@order.id, error_msg:""}.to_json and return

  end

  def weixin_get_user_info()

    @nickname = ""
    @avatar_url = ""

    if session[:nickname] && session[:avatarurl]
      @nickname = session[:nickname]
      @avatar_url = session[:avatarurl]
    else
      if session[:openid] && session[:access_token]

        $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
        user_info = $wechat_client.get_oauth_userinfo(session[:openid], session[:access_token])

        if user_info.result["errcode"] != "40003"
          @nickname = user_info.result["nickname"]
          @avatar_url = user_info.result["headimgurl"]

          session[:nickname] = @nickname
          session[:avatarurl] = @avatar_url
        end

      end
    end

    if session[:openid] && session[:access_token]
      $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])

      @sign_package = $wechat_client.get_jssign_package(request.original_url)
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

  def load_supporters(path)

    @page = params[:page].to_i
    @page = 1 if @page == 0
    @show_pager = false

    if @seller

      @supporters_count = @campaign.orders.completed.count
      @supporters = @campaign.orders.completed.select(
          "id,avatar_url,fullname,direct_donation").order(:id => :desc).page(@page).per(10)

      if @supporters.total_pages > 0 && @supporters.total_pages > @page

        @show_pager = true

        query = "?seller_id=" + params[:seller_id].to_s + "&" + {:page => @page + 1}.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&")

        @page_url = path + query

      end

    else
      @supporters_count = @campaign.orders.completed.count
      @supporters = @campaign.orders.completed.select(
          "id,avatar_url,fullname,direct_donation").order(:id => :desc).page(@page).per(10)

      if @supporters.total_pages > 0 && @supporters.total_pages > @page

        @show_pager = true

        query = "?seller_id=" + params[:seller_id].to_s + "&" + {:page => @page + 1}.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&")

        @page_url = path + query

      end
    end

  end
  private

  def manage_session_order
    logger.debug "1001"
    logger.debug session[:personal_campaign_slug]
    @campaign = Campaign.find_by_slug(session[:personal_campaign_slug])
    @campaign_total_count = 0
  end
end
