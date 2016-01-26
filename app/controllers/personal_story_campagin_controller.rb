class PersonalStoryCampaginController < ApplicationController
  layout "story_personal"
  before_filter :manage_session_order, only: [:index, :confirmation, :confirmation_weixin, :share]

  def index
    @is_wechat_browser = is_wechat_browser?

    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end
    if params[:id]
      @sellerreferral=SellerReferral.find(params[:id])
      @sellser=@sellerreferral.seller
    end

  end

  def confirmation
    @order.direct_donation=1 * 100
    @order.save

    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to personal_story_campagin_index_path, flash: {danger: message[0...-2]} and return
    end
    session[:order_id]=@order.id

    render json: @order.id and return
    redirect_to(checkout_weixin_native_pay_url(@campaign)) and return
  end

  def confirmation_weixin
    check_seller()

    @order.direct_donation=1
    @order.save

    if !@order.valid?
      message = ''
      @order.errors.each do |key, error|
        message = message + key.to_s.humanize + ' ' + error.to_s + ', '
      end
      redirect_to personal_story_index_path, flash: {danger: message[0...-2]} and return
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
    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
      weixin_address_init()

    end
  end

  def check_seller
    if session[:openid]
      @nick_name = params[:nickname]==nil ? "匿名" : params[:nickname]
      @avatar_url=params[:avatar_url]==nil ? "" : params[:avatar_url]
      @user = User.find_by uid: session[:openid], provider: "wx_seller"

      if !@user
        @user = User.new
        @user.password = "temp1234"
        @user.email = "seller"+SecureRandom.hex(2) + Time.now.to_i.to_s + "@11hao.com"
        @user.account_type = 1
        @user.uid = session[:openid]
        @user.provider = "wx_seller"

        unless @user.save
          redirect_to root_path and return
        end
        @user.update(email: "seller_"+@user.id.to_s+"@11hao.com")
      end

      @user_profile = @user.profile
      logger.debug "1001"

      if !@user_profile
        @user_profile = UserProfile.new
        @user_profile.user_id=@user.id
        @user_profile.first_name=@nick_name
        @user_profile.child_profile=false
        logger.debug "1002"
        logger.debug @user_profile
      else
        @user_profile.first_name = @nick_name
      end
      @user_profile.picture=@avatar_url
      logger.debug @user_profile.save

      logger.debug "1001"
      logger.debug @user_profile.id

      @seller = @user_profile.seller(@campaign)
      if @seller
        # @seller.video_file = params[:video_file]
        # @seller.save
      else
        @seller = Seller.create user_profile: @user_profile, campaign: @campaign
      end
      @seller.open_id=session[:openid]
      @seller.save
    end
  end

  def share
    # session[:openid]="oaR9aswmRKvGhMdb6kJCgIFKBpeg1"
    if session[:openid]
      check_seller()
      if params[:id]&&params[:id]!="-1"
        logger.debug "1001"
        logger.debug params[:id]

        @sellerreferral=SellerReferral.find(params[:id])
        @sellerretemp=SellerReferral.new
        @sellerretemp.seller_id=@seller.id
        @sellerretemp.sellerreferral_id=@sellerreferral.id
        @sellerretemp.is_success=false
        @sellerretemp.save
      else
        @sellerreferral=@seller.sellerreferral
        logger.debug "1001"
        logger.debug @sellerreferral
        if @sellerreferral
          @sellerretemp=@seller.seller_referrals.new
          @sellerretemp.sellerreferral_id=@sellerreferral.id
          @sellerretemp.is_success=false
          @sellerretemp.save
        else
          logger.debug "1002"
          @sellerretemp=@seller.seller_referrals.new
          @sellerretemp.is_success=false
          @sellerretemp.save
          @sellerretemp.sellerreferral_id=@sellerretemp.id
          @sellerretemp.save
        end
      end
    end

    render text: @sellerretemp.id
  end

  def share_result
    if params[:referall_id]
      @sellerreferral=SellerReferral.find(params[:referall_id])
      @sellerreferral.is_success=true
      @sellerreferral.save
    end
    render text: "success"
  end

  # ajax_supporters
  def supporters

    render partial: "supporters"
  end

  def weixin_get_user_info()

    @nickname = ""
    @avatar_url = ""

    if session[:openid] && session[:access_token]

      $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
      user_info = $wechat_client.get_oauth_userinfo(session[:openid], session[:access_token])

      if user_info.result["errcode"] != "40003"
        @nickname = user_info.result["nickname"]
        @avatar_url = user_info.result["headimgurl"]
      end

      @sign_package = $wechat_client.get_jssign_package(request.original_url)

    end

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

  private
  def manage_session_order
    @campaign = Campaign.find_by_slug("hbzjsj")

    @order = Order.find_by_id(session[:order_id])

    unless @order && @order.campaign_id == @campaign.id && @order.status == 0
      @order = @campaign.orders.new
      logger.debug '1001 @campaign.orders.new'
      logger.debug @order.id
    end
  end
end
