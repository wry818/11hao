class ShopController < ApplicationController
    before_filter :load_campaign, except: [:ajax_update_cart, :ajax_update_delivery, :ajax_order_summary, :ajax_add_offline_order, :ajax_resend_access_code, :ajax_update_order, :ajax_update_order_address, :ajax_query_weixin_order, :weixin_notify, :weixin_payment_get_req]
    before_filter :check_campaign_expired, only: [:shop, :category, :product, :checkout, :checkout_confirmation]
    before_filter :manage_session_order, only: [:show, :supporters, :shop, :category, :product]
    before_filter :load_seller, only: [:show, :supporters, :shop, :category, :product, :checkout, :checkout_confirmation]
    before_filter :log_ip, only: [:show, :supporters, :shop, :category, :product, :checkout, :checkout_confirmation]
    skip_before_filter :verify_authenticity_token, :only => [:weixin_notify]
    
    layout "shop"
    
    def show
      
        @help_text = "Help" + (@seller ? " " + @seller.user_profile.first_name : "") + " fundraise for " + @campaign.title
      
        @fb = {
            title: @help_text,
            description: @campaign.organizer_quote || view_context.strip_tags(@campaign.description),
            image: @campaign.logo,
            url: @seller ? short_campaign_url(@campaign, seller: @seller.referral_code) : short_campaign_url(@campaign)
        }

        logger.debug request.url
        logger.debug Rails.configuration.url_host + short_campaign_path(@campaign)

        qr = RQRCode::QRCode.new(request.url.split('?').first, :size => 10, :level => :h)

        @qr_url = qr.to_img.resize(200, 200).to_data_url

        weixin_jssdk_init()
        
    end
    
    def weixin_jssdk_init()
      
      $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
      @sign_package = $wechat_client.get_jssign_package(request.original_url)
      
    end
    
    def supporters
    end

    def shop
    end

    def category
        @category = Category.friendly.find(params[:category_id])
        redirect_to(short_campaign_url(@campaign), flash: { warning: "抱歉，我们没有找到这个类别" }) and return unless @category && @category.collection = @campaign.collection
    end

    def product
        @product = Product.friendly.find(params[:product_id])
        redirect_to(short_campaign_url(@campaign), flash: { warning: "抱歉，我们没有找到这个商品" }) and return unless @product && (@product.collections.include?(@campaign.collection) || @campaign.used_as_default?)

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
    
    def ajax_order_summary
      @order = Order.find_by_id(params[:order_id].to_i)
      
      if @order
        @campaign = @order.campaign
        
        render partial: "order_summary"
      else
        render text: 'fail'
      end
    end
    
    def ajax_update_cart
      render text: 'fail' and return unless params[:item] && params[:item][:order_id] && params[:item][:quantity] && params[:item][:campaign_id]

      @order = Order.find_by_id(params[:item][:order_id].to_i)
      
      seller_id = session[:seller_id] ? session[:seller_id] : nil

      if @order

        render text: 'fail' and return unless @order.status == 0 && @order.campaign_id == params[:item][:campaign_id].to_i
        @campaign = @order.campaign
        
      else
        
        @campaign = Campaign.active.where(:id=>params[:item][:campaign_id]).first
        render text: 'fail' and return unless @campaign
        
        seller_id = session[:seller_id] ? session[:seller_id] : nil
        @order = Order.create campaign_id: @campaign.id, seller_id: seller_id, delivery_method: (@campaign.delivery_type == 3 ? 1 : @campaign.delivery_type)
      
      end
      
      @no_more_discount = false
      @not_enough_discount = false

      #if the order in the session doesn't match, update the session to the order being updated
      session[:order_id] = @order.id

        if params[:item][:item_id]
             # updating an existing item's quantity in the cart, or deleting it
            existing_item = @order.items.find_by_id(params[:item][:item_id])
            render text: 'fail' and return unless existing_item
            
            product = existing_item.product
            item_updated_at = existing_item.updated_at.nil? ? existing_item.created_at : existing_item.updated_at
            option = existing_item.options.first
            check_property = false
             
            if option
              property = option.option_group_property
              
              if property
                check_property = true
              end
            end
            
            total_quantity = params[:item][:quantity].to_i
            
            if total_quantity > 0
                can_update_item = true
                
                # If item discounted, check campaign sold counter
                # if existing_item.is_discount
                #     counter = @campaign.purchase_limit - @campaign.discount_counter
                #     counter = counter + existing_item.quantity - total_quantity
                #
                #     if counter < 0
                #       can_update_item = false
                #
                #       @discount_avail_count = @campaign.purchase_limit - @campaign.discount_counter
                #       @discount_avail_count = @discount_avail_count + existing_item.quantity
                #
                #       if @discount_avail_count <= 0
                #         @no_more_discount = true
                #       else
                #         @not_enough_discount = true
                #       end
                #     end
                # end
                
                if can_update_item
                    counter = total_quantity - existing_item.quantity
              
                    if check_property
                      # check property available qty
                      if property.can_be_ordered?(counter)
                          if existing_item.is_discount
                              counter = @campaign.discount_counter - existing_item.quantity + total_quantity
                        
                              @campaign.update_attribute(:discount_counter, counter)
                          end
                          
                        counter = property.qty_counter - existing_item.quantity + total_quantity
              
                        existing_item.update_attribute(:quantity, total_quantity)                
                        property.update_attribute(:qty_counter, counter)
                      end
                    else
                      # check product available qty
                      if product.can_be_ordered?(counter)
                          if existing_item.is_discount
                              counter = @campaign.discount_counter - existing_item.quantity + total_quantity
                    
                              @campaign.update_attribute(:discount_counter, counter)
                          end
                          
                        counter = product.qty_counter - existing_item.quantity + total_quantity
                
                        existing_item.update_attribute(:quantity, total_quantity)                
                        product.update_attribute(:qty_counter, counter)
                      end
                    end
                end
            else
              if check_property
                # update property.qty_counter
                if property && !property.inventory_last_update_time.nil? 
                  if property.inventory_last_update_time < item_updated_at
                    counter = property.qty_counter - existing_item.quantity
                  
                    property.update_attribute(:qty_counter, counter)
                  end
                end
              else
                # update item.product.qty_counter
                if product && !product.inventory_last_update_time.nil? 
                  if product.inventory_last_update_time < item_updated_at
                    counter = product.qty_counter - existing_item.quantity
                  
                    product.update_attribute(:qty_counter, counter)
                  end
                end
              end
              
              # Decrease sold counter if item discounted
              if existing_item.is_discount
                  counter = @campaign.discount_counter - existing_item.quantity
                  
                  @campaign.update_attribute(:discount_counter, counter)
              end
              
              # remove the item
              existing_item.destroy
            end
        else
            # adding a new item from the product page
            render text: 'fail' and return unless params[:item][:product_id]
            @product = Product.find_by_id(params[:item][:product_id].to_i)
            render text: 'fail' and return unless @product && (@product.collections.include?(@campaign.collection) || @campaign.used_as_default?)
            
            if params[:item][:options]
                params[:item][:options].each do |option|
                    @option_group = OptionGroup.find_by_id(option[:option_group_id])
                    render text: 'fail' and return unless @option_group && !@option_group.deleted && @option_group.product_id == @product.id
                    @option_value = option[:value]
                    unless @option_value.blank?
                        if @option_group.is_dropdown?
                            @property = @option_group.option_group_properties.find_by_id(@option_value)
                            render text: 'fail' and return unless @property && !@property.deleted
                        end
                    end
                end
            end
            
            can_create_item = false
            total_quantity = params[:item][:quantity].to_i
            
            if @option_group
              if @property
                # check property available qty
                can_create_item = @property.can_be_ordered?(total_quantity)
              else
                # check product available qty
                can_create_item = @product.can_be_ordered?(total_quantity)
              end
            else
              # check product available qty
              can_create_item = @product.can_be_ordered?(total_quantity)
            end
            
            @discount = 1
            @discount_quantity = 0
            @normal_quantity = total_quantity
        
            if can_create_item
              if params[:add_discount] == "1" # Want to add discount item
                if @campaign.is_discount?
                  # @discount = (100 - @campaign.discount) / 100.0
                  
                  avail_discount = total_quantity   # @campaign.purchase_limit - @campaign.discount_counter
              
                  if avail_discount >= total_quantity
                      @campaign.update_attribute(:discount_counter, @campaign.discount_counter + total_quantity)
                      @discount_quantity = total_quantity
                      @normal_quantity = 0
                  else
                    can_create_item = false # Not enough discount products, do not create item
                    
                    @discount_avail_count = avail_discount
                    
                    if @discount_avail_count <= 0
                      @no_more_discount = true
                    else
                      @not_enough_discount = true
                    end
                    
                    # if avail_discount > 0
                    #     @campaign.update_attribute(:discount_counter, @campaign.purchase_limit)
                    #     @discount_quantity = avail_discount
                    #     @normal_quantity = total_quantity - @discount_quantity
                    # end
                  end
                else
                  can_create_item = false # Not enough discount products, do not create item
                  
                  @no_more_discount = true
                end
              end
                
                if can_create_item
                  # Add item for discount price
                  if @discount_quantity > 0
                      new_item = Item.create product_id: @product.id, quantity: @discount_quantity

                      new_item.delivery_method = @product.fulfillment_method
                      new_item.delivery_status = 1  # wait for delivery
                      new_item.delivery_updated_at = DateTime.now
                      new_item.base_amount = (@product.base_price * @discount * 100).ceil
                      new_item.donation_amount = (@product.default_donation_amount * @discount * 100).ceil
                      new_item.origin_base_amount = (@product.original_price * 100).ceil
                      new_item.origin_donation_amount = 0
                      new_item.is_discount = true

                      if @option_group
                          if @property
                            new_item.options.create option_group_id: @option_group.id, value: @property.value, 
                                price: @property.price * @discount, 
                                donation_amount: @property.donation_amount * @discount, 
                                option_group_property_id: @property.id

                            # Update item amount using property price and donation amount
                            new_item.base_amount = (@property.price * @discount * 100).ceil
                            new_item.donation_amount = (@property.donation_amount * @discount * 100).ceil

                            @property.update_attribute(:qty_counter, @property.qty_counter + @discount_quantity)
                          else
                            new_item.options.create option_group_id: @option_group.id, value: @option_value, 
                                price: @product.base_price * @discount, 
                                donation_amount: @product.default_donation_amount * @discount

                            @product.update_attribute(:qty_counter, @product.qty_counter + @discount_quantity)
                          end
                      else
                          @product.update_attribute(:qty_counter, @product.qty_counter + @discount_quantity)
                      end

                      new_item.save

                      add_item_to_order = true
                      @order.items.where(product_id: @product.id).each do |same_item|
                        if same_item.options_hash == new_item.options_hash
                            same_item.update_attribute(:quantity, same_item.quantity + @discount_quantity)
                            new_item.destroy
                            add_item_to_order = false
                            break
                        end
                      end

                      if add_item_to_order
                        @order.items << new_item
                      end
                  end
              
                  # Add item for normal price
                  if @normal_quantity > 0
                      new_item = Item.create product_id: @product.id, quantity: @normal_quantity

                      new_item.delivery_method = @product.fulfillment_method
                      new_item.delivery_status = 1  # wait for delivery
                      new_item.delivery_updated_at = DateTime.now
                      new_item.base_amount = (@product.base_price * 100).ceil
                      new_item.donation_amount = (@product.default_donation_amount * 100).ceil

                      if @option_group
                          if @property
                            new_item.options.create option_group_id: @option_group.id, value: @property.value, 
                                price: @property.price, 
                                donation_amount: @property.donation_amount, 
                                option_group_property_id: @property.id 

                            # Update item amount using property price and donation amount
                            new_item.base_amount = (@property.price * 100).ceil
                            new_item.donation_amount = (@property.donation_amount * 100).ceil

                            @property.update_attribute(:qty_counter, @property.qty_counter + @normal_quantity)
                          else
                            new_item.options.create option_group_id: @option_group.id, value: @option_value, 
                                price: @product.base_price, 
                                donation_amount: @product.default_donation_amount

                            @product.update_attribute(:qty_counter, @product.qty_counter + @normal_quantity)
                          end
                      else
                          @product.update_attribute(:qty_counter, @product.qty_counter + @normal_quantity)
                      end

                      new_item.save

                      add_item_to_order = true
                      @order.items.where(product_id: @product.id).each do |same_item|
                        if same_item.options_hash == new_item.options_hash
                            same_item.update_attribute(:quantity, same_item.quantity + @normal_quantity)
                            new_item.destroy
                            add_item_to_order = false
                            break
                        end
                      end

                      if add_item_to_order
                        @order.items << new_item
                      end
                  end
                  
                  # End create items
                end
            end
        end
         
        @is_add_to_cart = (params[:is_add_to_cart]=="1")
        
        if params[:parent_page]=="checkout"
          render partial: "cart_modal", locals: {parent_page: :checkout}
        else
          render partial: "cart_modal", locals: {parent_page: :other}
        end
    end

    def ajax_update_delivery
        @response = {}
        unless params[:order_id] && params[:delivery_method]
            @response[:error] = "Invalid parameters"
            render json: @response and return
        end

        @order = Order.find_by_id(params[:order_id].to_i)
        unless @order && @order.status == 0
            @response[:error] = "Invalid order"
            render json: @response and return
        end

        @order.delivery_method = params[:delivery_method]
        @order.calculate_fees!

        @response = {
            shipping_fee: view_context.long_price(@order.shipping_fee/100.0),
            processing_fee: view_context.long_price(@order.processing_fee_supporter/100.0),
            grand_total: view_context.long_price(@order.grandtotal/100.0),
            show_shipping: @order.delivery_method == 2,
            show_processing: @order.campaign.charge_processing_to_supporter
        }
        render json: @response
    end

    def checkout
      if session[:is_personal]
        @is_personal=session[:is_personal]
      else
        @is_personal=false
      end
      if params[:direct_donation]
        seller_id = session[:seller_id] ? session[:seller_id] : nil
        @order = Order.create campaign_id: @campaign.id, seller_id: seller_id, direct_donation: (params[:direct_donation].to_f * 100)
      elsif session[:order_id]
        @order = Order.find_by_id(session[:order_id])
        unless @order && @order.campaign_id == @campaign.id && @order.status == 0 && @order.valid_order?
          redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
        end
      else
          redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
      end
      
      #This is the first place the fees are calculated
      @order.calculate_fees!
      
      session[:confirmation_order_id] = nil
      
      @is_wechat_browser = is_wechat_browser?
      if is_wechat_browser?
        
        weixin_get_user_info()
        @weixin_init_success = true # Do weixin_payment_init at the time user clicks to pay, see weixin_payment_get_req
        # weixin_payment_init(@order)
        weixin_address_init()
        
      end
      
    end
    
    def weixin_native_pay
      
      if params[:direct_donation]
        seller_id = session[:seller_id] ? session[:seller_id] : nil
        @order = Order.create campaign_id: @campaign.id, seller_id: seller_id, direct_donation: (params[:direct_donation].to_f * 100)
      elsif session[:order_id]
        @order = Order.find_by_id(session[:order_id])
        unless @order && @order.campaign_id == @campaign.id && @order.status == 0 && @order.valid_order?
          redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
        end
      else
          redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
      end
      
      #This is the first place the fees are calculated
      @order.calculate_fees!
      
      if !is_wechat_browser?
        
        # weixin_native_payment_init(@order.grandtotal, order)
        weixin_native_payment_init(@order)
        
      end
      
    end
    
    def weixin_native_payment_init(order)
    
      r = Random.new
      num = r.rand(1000...9999)
      
      @weixin_init_success = false
      @out_trade_no = DateTime.now.strftime("%Y%m%d%H%M%S") + num.to_s
      @notify_url = root_url + 'checkout/weixin_notify'

      bodytxt="11号公益圈订单"
      if order.campaign.slug=="support-lanlan"
        bodytxt="为幼儿瘫母撑起希望"
      end

      params = {
        body: bodytxt,
        out_trade_no: @out_trade_no,
        # total_fee: 1,
        total_fee: order.grandtotal,
        spbill_create_ip: '127.0.0.1',
        notify_url: @notify_url,
        trade_type: 'NATIVE' # could be "JSAPI" or "NATIVE",
      }

      r = WxPay::Service.invoke_unifiedorder params
      @weixin_init_success = false
      @qr_url = "#"
    
      if r["return_code"] == 'SUCCESS' && r["result_code"] == 'SUCCESS'
        
        @weixin_init_success = true
        
        order.out_trade_no = @out_trade_no
        order.save

        qr = RQRCode::QRCode.new( r["code_url"], :size => 5, :level => :h )
        @qr_url = qr.to_img.resize(300, 300).to_data_url
      
      end

    end
    
    def weixin_payment_get_req
      order = Order.find_by_id(params[:id])
      
      if order && !order.completed?
        weixin_payment_init order
        
        if @weixin_init_success
          render json: {appId: @js_app_id, 
            timeStamp: @js_timestamp, 
            nonceStr: @js_noncestr, 
            package: @package,
            signType: "MD5",
            paySign: @js_pay_sign}.to_json and return
        end
      end
      
      render json: {appId: "", 
        timeStamp: "", 
        nonceStr: "", 
        package: "",
        signType: "MD5",
        paySign: ""}.to_json and return
    end
    
    def weixin_payment_init(order)
    
      if session[:openid]
        
        r = Random.new
        num = r.rand(1000...9999)
        out_trade_no = DateTime.now.strftime("%Y%m%d%H%M%S") + num.to_s #生产随机订单号，这里用当前时间加随机数，保证唯一
        bodytxt="11号公益圈订单"
        if order.campaign.slug=="support-lanlan"
          bodytxt="为幼儿瘫母撑起希望"
        end
        if order.campaign.slug=="hbzjsj"
          bodytxt="红包拯救世界"
        end
        params = {
          body: bodytxt,
          out_trade_no: out_trade_no,
          # total_fee: 1,
          total_fee: order.grandtotal,
          spbill_create_ip: '127.0.0.1',
          notify_url: root_url + 'checkout/weixin_notify',
          trade_type: 'JSAPI', # could be "JSAPI" or "NATIVE",
          # openid: 'oaR9aswmRKvGhMdb6kJCgIFKBpeg' # required when trade_type is `JSAPI`
          # openid: 'oaR9as940svyxuTEuKZgeibjC7ng'
          openid: session[:openid]
        }

        r = WxPay::Service.invoke_unifiedorder params
        
        @weixin_init_success = false
        
        if r["return_code"] == 'SUCCESS' && r["result_code"] == 'SUCCESS'

          @js_noncestr = SecureRandom.uuid.tr('-', '')
          @js_timestamp = Time.now.getutc.to_i.to_s
          @js_app_id = r["appid"]
          @package = "prepay_id=" + r["prepay_id"]

          params_pre_pay_js = {
            appId: @js_app_id,
            nonceStr: @js_noncestr,
            package: @package,
            timeStamp: @js_timestamp,
            signType: 'MD5'
          }

          @js_pay_sign = WxPay::Sign.generate(params_pre_pay_js)
          @weixin_init_success = true
        
          order.out_trade_no = out_trade_no
          order.save
          
        end

      end
      
    end

    def weixin_notify
      
      # logger.info "hahahahahahahahahahahahahahahaha"
      
      result = Hash.from_xml(request.body.read)["xml"]
      
      if WxPay::Sign.verify?(result)
        
        open_id = result["openid"]
        out_trade_no = result["out_trade_no"]
        logger.info out_trade_no
        
        order = Order.where(:out_trade_no => out_trade_no).first
        
        if order
          
          if open_id.present?
            order.open_id = open_id
          end
          
          order.status = 3
          order.save
          
        end
        
        # find your order and process the post-paid logic.
        render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)

      else
        
        render :xml => {return_code: "SUCCESS", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
        
      end

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
    
    def ajax_update_order
            
      order_make_anonymous = params[:order_make_anonymous]
      format_order_time = params[:format_order_time]
      fullName = params[:fullName]
      avatar_url = params[:avatar_url]
      provinceName = params[:provinceName]
      cityName = params[:cityName]
      cityAreaName = params[:cityAreaName]
      addressLine = params[:addressLine]
      receiveName = params[:receiveName]
      phoneNumber = params[:phoneNumber]
      zipCode = params[:zipCode]
      
      order = Order.find_by_id(params[:order_id])
      
      if order.needs_shipping
        
        if receiveName
          order.address_fullname = receiveName
        end
      
        if addressLine
          order.address_line_one = addressLine
        end
      
        if cityName
          order.address_city = cityName
        end
      
        if provinceName
          order.address_state = provinceName
        end
      
        if zipCode
          order.address_postal_code = zipCode
        end

        if phoneNumber
          order.phone_number = phoneNumber
        end
      
        if cityAreaName
          order.address_city_area = cityAreaName
        end
        
      end
      
      if fullName
        order.fullname = fullName
      end
      
      if avatar_url && avatar_url.length > 0
        order.avatar_url = avatar_url
      end
      
      if order_make_anonymous
        order.make_anonymous = order_make_anonymous
      end
      
      if session[:openid]
        order.open_id = session[:openid]
      end
      
      order.status = 3
      order.save
      
      # openid = "oaR9aswmRKvGhMdb6kJCgIFKBpeg"
      # send_template_message(openid, order, format_order_time)
      
      if session[:openid]
       
       openid = session[:openid]
       if !(order.campaign.slug=="support-lanlan")
         send_template_message(openid, order, format_order_time)
       end
       
        # $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
#         $client.send_text_custom(session[:openid], "支付成功！订单编号" + order.id.to_s.rjust(8,'0') + "。11号公益圈感谢您的支持！")
        
      end
      
      if order.seller_id

        # seller = Seller.find_by_id(order.seller_id)
        #
        # $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
        #
        # articles = [
        #   {
        #     title: "有顾客购买了您的商品！",
        #     description: "点击查看当前的筹款排名。",
        #     url: request.protocol + request.host + "/seller/" + seller.referral_code + "/seller_ladder"
        #   }
        # ]
        # if !(order.campaign.slug=="support-lanlan")
        #   $wechat_client.send_news_custom(seller.user_profile.user.uid, articles)
        # end
        
      end
            
      session[:confirm_order_id] = order.id
      session[:order_id] = nil

      if (order.campaign.slug=="support-lanlan")
        render text: "success_lanlan" and return
      end

      render text: "success"
      
    end
    
    def ajax_update_order_address
      
      order_make_anonymous = params[:order_make_anonymous]
      fullName = params[:fullName]
      avatar_url = params[:avatar_url]
      provinceName = params[:provinceName]
      cityName = params[:cityName]
      cityAreaName = params[:cityAreaName]
      addressLine = params[:addressLine]
      receiveName = params[:receiveName]
      phoneNumber = params[:phoneNumber]
      zipCode = params[:zipCode]
      
      order = Order.find_by_id(params[:order_id])
      
      if receiveName
        order.address_fullname = receiveName
      end
      
      if addressLine
        order.address_line_one = addressLine
      end
      
      if cityName
        order.address_city = cityName
      end
      
      if provinceName
        order.address_state = provinceName
      end
      
      if zipCode
        order.address_postal_code = zipCode
      end
      
      if fullName
        order.fullname = fullName
      end
      
      if avatar_url && avatar_url.length > 0
        order.avatar_url = avatar_url
      end
      
      if phoneNumber
        order.phone_number = phoneNumber
      end
      
      if cityAreaName
        order.address_city_area = cityAreaName
      end
      
      if order_make_anonymous
        order.make_anonymous = order_make_anonymous
      end
      
      order.save
      
      render text: "success"
      
    end
    
    def send_template_message(openid, order, format_order_time)
      
      # touser = "oaR9aswmRKvGhMdb6kJCgIFKBpeg"
      touser = openid
      template_id = "EnyULkSzskM-dYaof4tAGvueGVjkglhNfObOVdKWsgk"
      url = ""
      topcolor = "#FF0000"
      
      campaign_name = order.campaign.title
      group_name = order.campaign.organization.name
      price = view_context.long_price(order.grandtotal/100.0)
      # time = order.updated_at.strftime("%Y年%m月%d日 %H:%M:%S")
      
      # puts campaign_name
      # puts group_name
      # puts price.to_s
      # puts format_order_time
      
      if order.campaign.used_as_default?
        msg="您的订单已经提交成功，感谢您的支持！\n\n简单公益，只因有你。\n"
      else
        msg="您的订单已经提交成功！\n感谢您的支持，您本次购买的商品将为" + group_name + "助力。\n\n简单公益，只因有你。\n"
      end
      
      data = {
        first: {
          value:msg,
          color:"#000000"
        },
        keyword1: {
          value:order.id.to_s.rjust(8,'0'),
          color:"#000000"
        },
        keyword2: {
          value:format_order_time,
          color:"#000000"
        },
        keyword3: {
          value:price.to_s + "元",
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
      
      send_dianping = false
      
      story_campaign_ids = ["1454046936","1450070083","1454041189","1429755460","1454040291","1449033862","1454046268",
      "1453430970","1454046097","1454297408","1454047162","1454297766","1454309232","1450162303","1454310248","1454304921",
      "1450162262","1437020617","1454383538"]
        
      if story_campaign_ids.include?(order.campaign.slug)
        send_dianping = true
        
        template_id = "C5g0aPRaXIDoCqtoZz2sBSGrD4EJqpxsDydYnLJ7Z9E"
        
        msg="感谢您的支持，您的红包将会资助#{group_name}。\n\n简单公益，只因有你。\n";
        
        data = {
          first: {
            value:msg,
            color:"#000000"
          },
          keyword1: {
            value:"用红包拯救世界!",
            color:"#000000"
          },
          keyword2: {
            value:format_order_time,
            color:"#000000"
          },
          remark: {
            value:"",
            color:"#000000"
          }
        }
      end

      $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
      response = $client.send_template_msg(touser, template_id, url, topcolor, data)
    
      if send_dianping
        articles = [
          {
            title: "【爱心专享】55元大众点评新年红包",
            url: "http://evt.dianping.com/event/mmbonus/new/newlanding.html?source=gongyi",
            picurl: request.protocol + request.host + "/images/redpack.jpg"
          }
        ]

        $client.send_news_custom(touser, articles)
      end
    
    end
    
    def checkout_support
      if session[:confirm_order_id]
        @order = Order.find_by_id(session[:confirm_order_id])
        
        unless @order && @order.campaign_id == @campaign.id && @order.completed? && @order.valid_order?
          redirect_to root_path and return
        end
        
        do_checkout_support
      else
        redirect_to root_path and return
      end
    end
    
    def checkout_support_page
      do_checkout_support
      
      render partial: "checkout_support_page" and return
    end
    
    def show_confirmation
      if session[:is_personal]
        @is_personal=session[:is_personal]
      else
        @is_personal=false
      end

      if session[:confirm_order_id]
        @order = Order.find_by_id(session[:confirm_order_id])
        
        if @order.campaign.used_as_default?
          @order.campaign_id = @campaign.id
          @order.save
        end
        
        unless @order && @order.campaign_id == @campaign.id && @order.completed? && @order.valid_order?
          redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
        end
      else
        redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
      end
      
      render "checkout_confirmation" and return
    end

    def checkout_confirmation

        @order = Order.find_by_id(params[:order_id])
        
        if @order.campaign.used_as_default?
          @order.campaign_id = @campaign.id
          @order.save
        end

        unless @order && @order.campaign_id == @campaign.id && @order.status == 0 && @order.valid_order?
          redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
        end

        @order.assign_attributes(order_params)
        @order.save
        
        if !@order.valid?
          message = ''
          @order.errors.each do |key, error|
            message = message + key.to_s.humanize + ' ' + error.to_s + ', '
          end
          redirect_to short_campaign_url(@campaign), flash: { danger: message[0...-2] } and return
        end

        redirect_to(checkout_weixin_native_pay_url(@campaign)) and return
        
        # redirect_to(short_campaign_url(@campaign), flash: { warning: "Invalid order" }) and return unless params[:card_number] && params[:cvv] && params[:expiration_month] && params[:expiration_year]
         
        # Stripe.api_key = Rails.configuration.stripe_api_key
#
#         response = PaymentApiResponse.new
#
#         begin
#           # if @campaign.organization.processor_id.present?
#           #                 transaction[:service_fee_amount] = (@order.processing_fee_supporter + @order.processing_fee_organization)/100.0
#           # end
#
#           req = {
#             :amount => @order.grandtotal.to_i,
#             :currency => "usd",
#             :description => "Raisy",
#             :card => params[:stripe_token],
#             :metadata => {
#               :order_id => params[:order_id]
#             }
#           }
#
#           stripe_hash = Stripe::Charge.create(req)
#
#           response.success = true
#           response.charge_id = stripe_hash[:id]
#           response.card_type = stripe_hash[:source][:brand]
#           response.card_last4 = stripe_hash[:source][:last4]
#           response.card_expiration_month = stripe_hash[:source][:exp_month]
#           response.card_expiration_year = stripe_hash[:source][:exp_year]
#         rescue => exception
#             response.success = false
#             response.message = exception.message
#
#             logger.info exception.message
#             redirect_to short_campaign_url(@campaign), flash: { warning: response.message } and return
#         end
#
#         if response.success?
#             @order.status = 3
#             @order.update_payment_api_data(response)
#             @order.save
#         else
#             logger.info response.message
#             redirect_to short_campaign_url(@campaign), flash: { warning: response.message } and return
#         end

        #Send a confirmation email
        # begin
        #     UserMailer.payment_confirmation(@order, @campaign).deliver
        # rescue => exception
        #     logger.info exception.message
        # end
        
        #Send registration codes for the items of which delivery method is email
        # begin
        #   items = @order.items.where(:delivery_method=>1).all
        #   count = items.count
        #
        #   if count>0
        #     items.each do |item|
        #       codes = RegistrationCode.where(:product_id=>item.product_id, :is_used=>0).limit(item.quantity).all
        #
        #       codes.each do |code|
        #         code.is_used = 1
        #         code.order_id = @order.id
        #         code.item_id = item.id
        #         code.save
        #
        #         code_array = []
        #         code_array << code.reg_code
        #
        #         AdminMailer.registration_codes(@order, code_array, "").deliver
        #       end
        #
        #       if codes.count > 0
        #         item.delivery_status = 2 # delivered
        #         item.save
        #       end
        #     end
        #   end
        # rescue => exception
        #     logger.info exception.message
        # end

        # session[:confirm_order_id] = @order.id
#         session[:order_id] = nil
#
#         if params[:order][:checkout_options]
#             params[:order][:checkout_options].each do |option|
#                 cog = CheckoutOptionGroup.find_by_id(option[:checkout_option_group_id])
#                 if cog && option[:value].present?
#                     if cog.is_dropdown?
#                         property = cog.checkout_option_group_properties.find_by_id(option[:value])
#                         @order.checkout_options.create(checkout_option_group_id: cog.id, value: property.value) if property
#                     else
#                         @order.checkout_options.create checkout_option_group_id: cog.id, value: option[:value]
#                     end
#                 end
#             end
#         end

    end
    
    def ajax_add_offline_order
      if !params[:items].present?
        render text: "fail" and return
      end
      
      campaign = Campaign.find_by_id(params[:camp_id])
      
      if !campaign || (!admin_user? && !sales_user? && !crs_user? && current_user.id != campaign.organizer_id)
        render text: "fail" and return
      end
      
      if params[:seller_id].present?
        seller = Seller.find_by_id(params[:seller_id])
        
        if !seller || seller.campaign_id != campaign.id
          render text: "fail" and return
        end
      else
        if !params[:first_name].present? || !params[:last_name].present?
          render text: "fail" and return
        end
        
        user = User.new
        user.password = "temp1234"
        user.email = SecureRandom.hex(4) + "@raisy.com"
        user.account_type = 1
        user.is_fake = true
        
        #save user
        unless user.save
          render text: "fail" and return
        end
        
        profile = UserProfile.create user: user, first_name: params[:first_name], last_name: params[:last_name], child_profile: false
        seller = Seller.create user_profile: profile, campaign: campaign, grade: params[:grade], homeroom: params[:leader]
      end
      
      order = Order.create campaign_id: campaign.id, seller_id: seller.id, is_offline: true,
        delivery_method: (campaign.delivery_type == 3 ? 1 : campaign.delivery_type)
      
      params[:items].each do |it|
        item = it[1]
        qty = item[:qty].to_i
        
        if qty<=0
          render text: 'fail' and return
        end
        
        product = Product.find_by_id(item[:prod_id])
        
        if !product || !product.collections.include?(campaign.collection)
          render text: 'fail' and return
        end
        
        @option_group = nil
        @property = nil
        
        if item[:option_group].present?
          @option_group = OptionGroup.find_by_id(item[:option_group])
          
          if !@option_group || @option_group.deleted || @option_group.product_id != product.id
            render text: 'fail' and return
          end
          
          if item[:option_value].present?
            if @option_group.is_dropdown?
                @property = @option_group.option_group_properties.find_by_id(item[:option_value])
                
                if !@property || @property.deleted
                  render text: 'fail' and return
                end
            end
          end
        end
        
        new_item = Item.create product_id: product.id, quantity: qty

        new_item.delivery_method = product.fulfillment_method
        new_item.delivery_status = 1  # wait for delivery
        
        if [1,2].include?(new_item.delivery_method)
          new_item.delivery_status = 2 # delivered
        end
        
        new_item.delivery_updated_at = DateTime.now
        new_item.base_amount = (product.base_price * 100).ceil
        new_item.donation_amount = (product.default_donation_amount * 100).ceil

        if @option_group
            if @property
              new_item.options.create option_group_id: @option_group.id, value: @property.value, 
                  price: @property.price, 
                  donation_amount: @property.donation_amount, 
                  option_group_property_id: @property.id 

              # Update item amount using property price and donation amount
              new_item.base_amount = (@property.price * 100).ceil
              new_item.donation_amount = (@property.donation_amount * 100).ceil
            else
              new_item.options.create option_group_id: @option_group.id, value: params[:option_value], 
                  price: product.base_price, 
                  donation_amount: product.default_donation_amount
            end
        end

        new_item.save

        add_item_to_order = true
        order.items.where(product_id: product.id).each do |same_item|
          if same_item.options_hash == new_item.options_hash
              same_item.update_attribute(:quantity, same_item.quantity + qty)
              new_item.destroy
              add_item_to_order = false
              break
          end
        end

        if add_item_to_order
          order.items << new_item
        end
      end
      
      order.status=3
      order.save
      
      render text: "success" and return
    end
    
    def ajax_resend_access_code
      begin
        email = params[:email]
      
        if !current_user || !email.present?
          render text: "fail" and return
        end
      
        item = Item.find_by_id(params[:item_id])
      
        if !item
          render text: "fail" and return
        end
      
        order = item.order
      
        if !order.completed?
          render text: "fail" and return
        end
      
        campaign = order.campaign
      
        if campaign.organizer_id != current_user.id && !admin_user? && !sales_user? && !crs_user?
          render text: "fail" and return
        end
      
        exist_codes = item.registration_codes.select(:reg_code).all
        code_array = exist_codes.collect(&:reg_code)
      
        if exist_codes.count < item.quantity
          codes = RegistrationCode.where(:product_id=>item.product_id, :is_used=>0).limit(item.quantity-exist_codes.count).all
        
          codes.each do |code|
            code.is_used = 1
            code.order_id = order.id
            code.item_id = item.id
            code.save
          
            code_array << code.reg_code
          end
        end
      
        code_array.each do |code|
          AdminMailer.registration_codes(order, [code], email).deliver
        end
      
        if code_array.count > 0
          item.delivery_status = 2 # delivered
          item.save
        end
      
        render text: code_array.join(", ") and return
      rescue
        render text: "fail" and return
      end
    end
    
    private
    # Using a private method to encapsulate the permissible parameters is
    # just a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.

    def load_campaign
      begin
        @campaign = Campaign.friendly.find(params[:id])
        
        if !@campaign.active?
          redirect_to root_url and return
        end
        
        if !@campaign.ent_campaign?
          @organization_campaign = Campaign.storefronts.where(:organization_id=>@campaign.organization_id).first
        end
        
        @admin_viewer = current_user && (@campaign.organizer == current_user || admin_user?)
        @fb = {
            title: @campaign.title,
            description: @campaign.organizer_quote || view_context.strip_tags(@campaign.description),
            image: @campaign.logo,
            url: short_campaign_url(@campaign)
        }
      rescue
        redirect_to(root_url, flash: { warning: "抱歉，我们没有找到这个筹款团队！" }) and return
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
          @visit_log.nickname = weixin_get_user_info
          @visit_log.save
        end
      end
    end

    def check_campaign_expired
        redirect_to(short_campaign_url(@campaign), flash: { warning: "抱歉，这个筹款团队已经结束。" }) and return if @campaign.expired?
    end

    def manage_session_order
      @order = Order.find_by_id(session[:order_id])
      
      unless @order && @order.campaign_id == @campaign.id && @order.status == 0
        @order = Order.new
      end
    end
    
    def load_seller
      if params[:seller].present?
        referral_code = params[:seller]
        
        seller = Seller.where(referral_code: params[:seller]).first
        
        if seller && seller.campaign_id == @campaign.id
          @seller = seller
          
          session[:seller_id] = seller.id
        end
      else
        if session[:seller_id]
          seller = Seller.find_by_id(session[:seller_id])
          
          if seller && seller.campaign_id == @campaign.id
            @seller = seller
          end
        end
      end
      
      if @seller
        @ent_url = ent_url(@campaign, @seller)
      else
        @ent_url = ent_url(@campaign)
      end
      
      @user_is_seller = false
      if @seller && session[:openid]
        
        user = User.find_by uid: session[:openid], provider: "wx"
    
        if user
          
          user_profile = user.profile
          
          if user_profile
              
            has_seller = Seller.where(campaign_id: @campaign.id, user_profile_id: user_profile.id).first
            
            if has_seller
              
              @user_is_seller = true
              
            end
              
          end
          
        end
        
      end
      
    end

    def order_params
        params.require(:order).permit :fullname, :email, :billing_zip_code, :address_fullname, :address_line_one, :address_line_two, :address_city, :address_city_area,
                                                             :address_state, :address_postal_code, :address_country, :seller_id, :delivery_method,
                                                             :make_anonymous, :phone_number
    end

    def ent_url(campaign, seller = nil)

        url = "#{Rails.configuration.ent_url_base}?linkName=#{Rails.configuration.ent_url_link_name}&redirectURL=view_all_products.cmd&groupId=#{@campaign.organization.entertainment_customer_id}"

        if seller.present? && seller.referral_code.present?
            url += '&sellerId='+ seller.referral_code
        end

        url
    end
    
    def do_checkout_support
      @page = params[:page].to_i
      @page = 1 if @page == 0
      @show_pager = false
      @campaigns = Campaign.isnot_destroy.active.real.order(:id => :desc).page(@page).per(5)
    
      if @campaigns.total_pages > 0 && @campaigns.total_pages > @page
        @show_pager = true
        
        query = "?" + {:page => @page + 1}.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")
          
        @page_url = checkout_support_page_path(@campaign) + query
      end
    end

end
