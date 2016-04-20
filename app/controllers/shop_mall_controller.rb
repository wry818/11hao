class ShopMallController < ApplicationController
  layout "shop_weixin"

  def pay

  end

  def product
    @product = Product.friendly.find(params[:product_id])

    # redirect_to(short_campaign_url(@campaign), flash: { warning: "抱歉，我们没有找到这个商品" }) and return unless @product && (@product.collections.include?(@campaign.collection) || @campaign.used_as_default?)

    @category = params[:category_id] ? Category.friendly.find(params[:category_id]) : false
    @qty_avail = @product.need_check_inventory ? @product.qty_available-@product.qty_counter : 99999

    @option_group = @product.option_groups.active.first
    @option_group_properties = []
    @option_group_is_dropdown = false
    @discount = 1
    @min_price = (@discount * @product.total_price * 100).ceil/100.0
    @max_price = (@discount * @product.total_price * 100).ceil/100.0
    @min_origin_price = (@product.original_price * 100).ceil/100.0
    @max_origin_price = (@product.original_price * 100).ceil/100.0

    # if @campaign.is_discount?
    #     @discount = (100 - @campaign.discount)/100.0
    # end

    if @option_group
      @min_price = 99999
      @max_price = 0
      @min_origin_price = 99999
      @max_origin_price = 0

      has_properties = false

      @option_group.option_group_properties.active.each do |property|
        @option_group_is_dropdown = true

        if property.can_be_ordered?(1)
          has_properties = true

          prop_price = (property.total_price * @discount * 100).ceil/100.0
          prop_origin_price = (@product.original_price * 100).ceil/100.0

          @option_group_properties << property

          if prop_price<=@min_price
            @min_price=prop_price
          end

          if prop_price>=@max_price
            @max_price=prop_price
          end

          if prop_origin_price<=@min_origin_price
            @min_origin_price=prop_origin_price
          end

          if prop_origin_price>=@max_origin_price
            @max_origin_price=prop_origin_price
          end
        end
      end

      if !has_properties
        @min_price = (@discount * @product.total_price * 100).ceil/100.0
        @max_price = (@discount * @product.total_price * 100).ceil/100.0
        @min_origin_price = (@product.original_price * 100).ceil/100.0
        @max_origin_price = (@product.original_price * 100).ceil/100.0
      end
    else
      @min_price = (@discount * @product.total_price * 100).ceil/100.0
      @max_price = (@discount * @product.total_price * 100).ceil/100.0
      @min_origin_price = (@product.original_price * 100).ceil/100.0
      @max_origin_price = (@product.original_price * 100).ceil/100.0
    end
  end

  def party_index
    logger.debug session[:openid]
    params[:id]=""
    if params[:partyid]&&params[:partyid].to_s.length>0
      params[:id]=params[:partyid].split("_")[1]
    end
    @party=Party.find(params[:id]);
    if !@party
      redirect_to root_url
    end
    @is_participant=1
    if session[:openid]
      count= @party.participants.where(:open_id => session[:openid], :status => 1).count
      if count==0
        @is_participant=2
      end
    else
      @is_participant=3
    end
    @is_participant=2
  end

  def party_ticket_view

  end

  def ajax_create_participant

    if params[:partyid]
      @party=Party.find(params[:partyid]);
    end
    if !@party||!session[:openid]
      render :text => "error" and return
    end

    # session[:openid]="oaR9as9LCc7KFlh1dih3uXEy_5-w"
    @participent= @party.participants.where(:open_id => session[:openid]).first
    if @participent
      @participent.assign_attributes partycipent_params
    else
      @participent=Participant.new partycipent_params
    end

    @participent.parties_id= @party.id
    r = Random.new
    num = r.rand(1000...9999)
    @participent.code=DateTime.now.strftime("%Y%m%d%H%M%S") + num.to_s

    weixin_get_user_info();
    @participent.fullname=@nickname
    @participent.avatar_url=@avatar_url
    @participent.open_id=session[:openid]

    if @party.has_fee&&@party.has_fee?
      @order = Order.new
      @order.direct_donation = @party.fee_count
      weixin_get_user_info
      @order.fullname=@nickname
      @order.avatar_url=@avatar_url
      if @order.direct_donation==0
        @order.direct_donation=500;
      end
      @order.save
      @participent.status=2
      @participent.orders_id=@order.id
    else
      @participent.status=1

    end

    @participent.save
    if @order
      logger.debug "1111"
      render :json => {success: true, order_id: @order.id} and return
    end


    render :json => {success: true} and return
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
  end

  private
  def partycipent_params
    params.require(:partycipent).permit :name, :tel, :remark
  end
end
