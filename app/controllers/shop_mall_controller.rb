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
    if is_wechat_browser?

      weixin_get_user_info()
      @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
    end
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

    # @is_participant=2
    path = partyview_participants_path
    load_participants(path)

    # ajax_update_participant
  end

  def partyview_participants
    party_id = 0
    if params[:party_id]
      party_id = params[:party_id]
    end
    path = partyview_participants_path

    load_party_paticipants(party_id, path)
  end
  def load_party_paticipants(partyid, path)

    @party = Party.find(partyid)

    load_participants(path)

    render partial: "participants" and return

  end
  def load_participants(path)

    @page = params[:page].to_i
    @page = 1 if @page == 0
    @show_pager = false

      @participants_count = @party.participants.completed.count
      @participants = @party.participants.completed.order(:id => :desc).page(@page).per(10)

      if @participants.total_pages > 0 && @participants.total_pages > @page

        @show_pager = true

        query = "?party_id=#{@party.id}&" + {:page => @page + 1}.map { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join("&")

        @page_url = path + query

      end

  end

  def party_ticket_view
    @participant=Party.find(params[:id])
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
    if @participent.status==1
      if session[:openid]
        msg="\n\n点击查看报名凭证";
        logger.debug party_ticket_view_preview_url(@participent.id)
        send_template_message(session[:openid],@participent.party.name,
                              @participent.party.begin_time.localtime.strftime('%Y-%m-%d %H:%M').to_s,
                              msg,party_ticket_view_preview_url(@participent.id))
      end
    end
    if @order
      logger.debug "1111"
      render :json => {success: true, order_id: @order.id} and return
    end


    render :json => {success: true} and return
  end

  def ajax_update_participant
    # params[:order_id]=1043
    # session[:openid]="oaR9as9LCc7KFlh1dih3uXEy_5-w"
    order = Order.find_by_id(params[:order_id])
    if order
        participant=Participant.find_by(:orders_id=>order.id)
        if participant&&session[:openid]
           msg="\n\n点击查看报名凭证";
          logger.debug party_ticket_view_preview_url(participant.id)
          send_template_message(session[:openid],participant.party.name,
                                participant.party.begin_time.localtime.strftime('%Y-%m-%d %H:%M').to_s,
                                msg,party_ticket_view_preview_url(participant.id))
        end
    end
    render text: "success"
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
  # 活动报名成功
  def send_template_message(openid,title_msg,format_order_time,remark,url)

    # touser = "oaR9aswmRKvGhMdb6kJCgIFKBpeg"
    touser = openid
    template_id = "C5g0aPRaXIDoCqtoZz2sBSGrD4EJqpxsDydYnLJ7Z9E"
    url =url
    topcolor = "#FF0000"

    msg="恭喜您，您报名活动已成功，并已生成电子凭证\n\n简单公益，只因有你。\n";
    data = {
        first: {
            value:msg,
            color:"#000000"
        },
        keyword1: {
            value:title_msg,
            color:"#000000"
        },
        keyword2: {
            value:format_order_time,
            color:"#000000"
        },
        remark: {
            value:remark,
            color:"#bf111a"
        }
    }
    $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
    response = $client.send_template_msg(touser, template_id, url, topcolor, data)

  end
end
