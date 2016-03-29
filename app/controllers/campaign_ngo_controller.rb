class CampaignNgoController < ApplicationController
  # layout "story_personal",:except => [:xyetjk, :lbflower,:lbxgy,:campaignview]
  layout "app_web"
  # ,:only => [:xyetjk, :lbflower,:lbxgy,:campaignview]
  before_filter :manage_session_order, only: [ :confirmation, :confirmation_weixin]

  def campaignview

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end
    id=0;
    if params[:id]
      campaign_id = params[:id]
      id=campaign_id.split("_")[1]
    end

    session[:personal_campaign_slug]=id
    path = campagin_ngo_campaignview_supporters_path

    load_campaign_page(id, path)

  end
  def campaignview_supporters

    campaign_id = 0
    if params[:campaign_id]
      campaign_id = params[:campaign_id]
    end
    path = campagin_ngo_campaignview_supporters_path

    load_campaign_supporter(campaign_id, path)

  end

  def lzds

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end


    campaign_slug = "zs1001"
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_lzds_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def lzds_supporters

    campaign_slug = "zs1001"
    path = campagin_ngo_lzds_supporters_path

    load_campaign_supporter(campaign_slug, path)

  end

  def lovehb

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end


    campaign_slug = "zs1002"
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_lovehb_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def lovehb_supporters

    campaign_slug = "zs1002"
    path = campagin_ngo_lovehb_supporters_path

    load_campaign_supporter(campaign_slug, path)

  end

  def xgst

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end


    campaign_slug = "zs1003"
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_xgst_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def xgst_supporters

    campaign_slug = "zs1003"
    path = campagin_ngo_xgst_supporters_path

    load_campaign_supporter(campaign_slug, path)

  end

  def shgs

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end


    campaign_slug = "gs1001"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_shgs_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def shgs_supporters

    campaign_slug = "gs1001"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    path = campagin_ngo_shgs_supporters_path

    load_campaign_supporter(campaign_slug, path)

  end
  def xyetjk

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end


    campaign_slug = "lb1001"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_xyetjk_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def xyetjk_supporters

    campaign_slug = "lb1001"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    path = campagin_ngo_xyetjk_supporters_path

    load_campaign_supporter(campaign_slug, path)

  end
  def lbxgy

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end


    campaign_slug = "lb1002"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_lbxgy_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def lbxgy_supporters

    campaign_slug = "lb1002"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    path = campagin_ngo_lbxgy_supporters_path

    load_campaign_supporter(campaign_slug, path)

  end
  def lbflower

    if(params[:order_id])
      order=Order.find(params[:order_id])
      if order
        @isback=order.direct_donation
      end
    end


    campaign_slug = "lb1003"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    session[:personal_campaign_slug]=campaign_slug
    path = campagin_ngo_lbflower_supporters_path

    load_campaign_page(campaign_slug, path)

  end
  def lbflower_supporters

    campaign_slug = "lb1003"
    campaign_slug=Campaign.find_by_slug(campaign_slug).id;
    path = campagin_ngo_lbflower_supporters_path

    load_campaign_supporter(campaign_slug, path)

  end
  def load_campaign_page(campaign_slug, path)

    @campaign = Campaign.find(campaign_slug)
    @campaign_total_count = @campaign.orders.completed.count

    @is_wechat_browser = is_wechat_browser?
    @share_url=request.protocol + request.host_with_port + "/checkout/campaign_" + @campaign.id.to_s
    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end

    load_supporters(path)
    log_ip()
  end
  def load_campaign_supporter(campaign_slug, path)

    @campaign = Campaign.find(campaign_slug)

    load_supporters(path)

    render partial: "supporters" and return

  end

  def log_ip
    if @campaign
      if session[:openid] && session[:access_token]
        query=CampaignVisitLog.where("campaign_id=:campaign_id and open_id=:open_id
          and visited_time>=:start_time and visited_time<:end_time",
                                     campaign_id: @campaign.id, open_id: session[:openid],
                                     start_time: Time.now.to_date, end_time: Time.now.to_date+1)
      else
        query=CampaignVisitLog.where("campaign_id=:campaign_id and remote_ip=:remote_ip
          and visited_time>=:start_time and visited_time<:end_time",
                                     campaign_id: @campaign.id, remote_ip: request.remote_ip,
                                     start_time: Time.now.to_date, end_time: Time.now.to_date+1)
      end


      @visit_log = query.first


      if !@visit_log
        @visit_log = CampaignVisitLog.new campaign_id: @campaign.id, visited_time: Time.now

        if @seller
          @visit_log.seller_id = @seller.id
        end

        @visit_log.open_id = session[:openid]
        @visit_log.remote_ip = request.remote_ip
        @visit_log.nickname = @nickname
        @visit_log.save
      end
    end
  end

  def confirmation
    logger.debug "1001"+params[:direct_donation].to_s
    @order = @campaign.orders.new
    @order.direct_donation=params[:direct_donation].present? ? params[:direct_donation].to_f*100 : 500
    if @order.direct_donation==0
      @order.direct_donation=500;
    end
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
    if params[:campaign_id]
      @campaign=Campaign.find(params[:campaign_id]);
    end


    @order = @campaign.orders.new

    if params[:seller_id]
      @seller = Seller.find_by_id(params[:seller_id])

      @order.seller_id=@seller.id if @seller
    end

    @order.direct_donation = params[:direct_donation].present? ? params[:direct_donation].to_f*100 : 500
    if @order.direct_donation==0
      @order.direct_donation=500;
    end
    @order.save

    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to campagin_ngo_lzds_path, flash: {danger: message[0...-2]} and return
    end

    # session[:order_id]=@order.id
    # session[:confirm_order_id]

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

        query = "?campaign_id=#{@campaign.id}&seller_id=" + params[:seller_id].to_s + "&" + {:page => @page + 1}.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&")

        @page_url = path + query

      end

    else
      @supporters_count = @campaign.orders.completed.count
      @supporters = @campaign.orders.completed.select(
          "id,avatar_url,fullname,direct_donation").order(:id => :desc).page(@page).per(10)

      if @supporters.total_pages > 0 && @supporters.total_pages > @page

        @show_pager = true

        query = "?campaign_id=#{@campaign.id}&seller_id=" + params[:seller_id].to_s + "&" + {:page => @page + 1}.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&")

        @page_url = path + query

      end
    end



  end
  private

  def manage_session_order
    logger.debug "1001"
    if session[:personal_campaign_slug]
      @campaign = Campaign.find(session[:personal_campaign_slug])
    end
    @campaign_total_count = 0
  end
end
