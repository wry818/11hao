class PersonalStoryCampaginController < ApplicationController
  layout "story_personal"
  before_filter :manage_session_order, only: [:index, :confirmation, :confirmation_weixin, :share, :log_ip, :index_old]
  before_filter :load_seller, only: [:index, :index_old]

  def index
    @is_wechat_browser = is_wechat_browser?

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end
    
    log_ip()
    
  end
  
  def index_old
    @is_wechat_browser = is_wechat_browser?

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end
    
    log_ip()
  end
  
  def sunflower
    
    @campaign = Campaign.find_by_slug("1450070083")
    @campaign_total_count = @campaign.orders.completed.count
    path = personal_story_campagin_sunflower_supporters_path
    
    @is_wechat_browser = is_wechat_browser?

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end
    
    load_seller()
    load_supporters(path)
    
    log_ip()
    
  end
  
  def sunflower_supporters
    
    @campaign = Campaign.find_by_slug("1450070083")
    path = personal_story_campagin_sunflower_supporters_path
    
    load_seller()
    load_supporters(path)
    
    render partial: "supporters" and return
    
  end

  def pulushi
    @campaign = Campaign.find_by_slug("1429755460")
    @campaign_total_count = @campaign.orders.completed.count
    path = personal_story_campagin_pulushi_supporters_path

    @is_wechat_browser = is_wechat_browser?

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end

    load_seller()
    load_supporters(path)

    log_ip()
  end

  def pulushi_supporters
    @campaign = Campaign.find_by_slug("1429755460")
    path = personal_story_campagin_pulushi_supporters_path

    load_seller()
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
      redirect_to personal_story_campagin_index_path, flash: {danger: message[0...-2]} and return
    end
    session[:order_id]=@order.id

    redirect_to(checkout_weixin_native_pay_url(@campaign)) and return
  end

  def confirmation_weixin
    @order = @campaign.orders.new
    
    if params[:seller_id]
      @seller = Seller.find_by_id(params[:seller_id])
      
      @order.seller_id=@seller.id if @seller
    end
    
    @order.direct_donation=1
    @order.save

    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to personal_story_campagin_index_path, flash: {danger: message[0...-2]} and return
    end
    
    session[:order_id]=@order.id
    session[:confirm_order_id]

    render json: @order.id and return
  end

  def show_confirmation

    if session[:confirm_order_id]
      @order = Order.find_by_id(session[:confirm_order_id])
      @campaign=@order.campaign

      if @order.campaign.used_as_default?
        @order.campaign_id = @campaign.id
        @order.save
      end

      unless @order && @order.completed? && @order.valid_order?
        redirect_to(personal_story_campagin_index_path, flash: {warning: "捐款失败请刷新后重试"}) and return
      end
    else
      redirect_to(personal_story_campagin_index_path, flash: {warning: "捐款失败请刷新后重试"}) and return
    end

    render "checkout_confirmation" and return
  end

  def index_red_pack
    # @seller=Seller.find_by_id(1)
    
    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()
    end
    
    @campaign = Campaign.find_by_id(params[:campaign_id])
    @share_link = request.original_url
    
    if @campaign
      check_seller
      
      # @share_link relies on slug, hbzjsj and so on
      if @seller
        if @campaign.slug == "1454046936"
          @share_link = request.protocol + request.host_with_port + "/checkout/sunflower?seller_id=" + @seller.id.to_s
        end
      end
      
      if session[:referral_seller_id]
        @referral_seller = Seller.find_by_id(session[:referral_seller_id])
      
        if @seller && @referral_seller && @seller.id != @referral_seller.id
          seller_referral = SellerReferral.where(:seller_id => @seller.id, :sellerreferral_id => @referral_seller.id).first
          
          if !seller_referral
            SellerReferral.create seller_id: @seller.id, sellerreferral_id: @referral_seller.id
          end
        end
      end
    end
  end

  def check_seller
    if session[:openid]
      @user = User.find_by uid: session[:openid], provider: "wx"

      if !@user
        @user = User.new
        @user.password = "temp1234"
        @user.email = "seller_" + SecureRandom.hex(2) + Time.now.to_i.to_s + "@11hao.com"
        @user.account_type = 1
        @user.uid = session[:openid]
        @user.provider = "wx"

        unless @user.save
          redirect_to root_path and return
        end
        
        @user.update(email: "seller_"+@user.id.to_s+"@11hao.com")
      end

      @user_profile = @user.profile
      
      if !@user_profile
        @user_profile = UserProfile.new
        @user_profile.user_id=@user.id
        @user_profile.first_name=@nickname || '匿名'
        @user_profile.child_profile=false
        @user_profile.picture=@avatar_url
        @user_profile.save
      end

      @seller = @user_profile.seller(@campaign)
      
      if !@seller
        @seller = Seller.create user_profile: @user_profile, campaign: @campaign, open_id: session[:openid]
      end
    end
  end

  def share
    # Not used and will remove later
    
    render text: ""
  end

  def share_result
    # Not used and will remove later
    
    render text: ""
  end

  # ajax_supporters
  def supporters

    render partial: "supporters"
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

      if @seller
        @visit_log = query.where(:seller_id=>@seller.id).first
      else
        @visit_log = query.first
      end

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
  private

  def manage_session_order
    
    @campaign = Campaign.find_by_slug("1454046936")
    @campaign_total_count = 0
    
  end
  
  def load_seller
    
    @has_seller = false
    @seller_referral_count = 0
    
    session[:referral_seller_id] = nil
    
    if params[:seller_id]
      @seller = Seller.find_by_id(params[:seller_id])
      
      if @seller
        @has_seller = true
        
        referral_ids = SellerReferral.where(:sellerreferral_id => @seller.id).pluck(:seller_id)
        
        @seller_referral_count = @campaign.orders.completed.where(:seller_id => referral_ids).count + @campaign.orders.completed.where(:seller_id => @seller.id).count
        
        session[:referral_seller_id] = @seller.id
      end
    end
    
  end
  
  def load_supporters(path)
    
    @page = params[:page].to_i
    @page = 1 if @page == 0
    @show_pager = false
    
    if @seller
      
      @supporters_count = @campaign.orders.completed.where(:seller_id => @seller.id).count
      @supporters = @campaign.orders.completed.where(:seller_id => @seller.id).select(
        "id,avatar_url,fullname,direct_donation").order(:id=>:desc).page(@page).per(10)
      
        if @supporters.total_pages > 0 && @supporters.total_pages > @page
          
          @show_pager = true

          query = "?seller_id=" + params[:seller_id].to_s + "&" + {:page => @page + 1}.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")

          @page_url = path + query
          
        end  

    else
      @supporters_count = @campaign.orders.completed.count
      @supporters = @campaign.orders.completed.select(
          "id,avatar_url,fullname,direct_donation").order(:id=>:desc).page(@page).per(10)

      if @supporters.total_pages > 0 && @supporters.total_pages > @page

        @show_pager = true

        query = "?seller_id=" + params[:seller_id].to_s + "&" + {:page => @page + 1}.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")

        @page_url = path + query

      end
    end    

  end
  
end
