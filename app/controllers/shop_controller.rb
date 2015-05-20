class ShopController < ApplicationController
    before_filter :load_campaign, except: [:ajax_update_cart, :ajax_update_delivery, :ajax_order_summary, :ajax_add_offline_order, :ajax_resend_access_code, :ajax_update_order]
    before_filter :check_campaign_expired, only: [:shop, :category, :product, :checkout, :checkout_confirmation]
    before_filter :manage_session_order, only: [:show, :supporters, :shop, :category, :product]
    before_filter :load_seller, only: [:show, :supporters, :shop, :category, :product, :checkout, :checkout_confirmation]
    
    layout "shop"
    
    def show
        @help_text = "Help" + (@seller ? " " + @seller.user_profile.first_name : "") + " fundraise for " + @campaign.title
      
        @fb = {
            title: @help_text,
            description: @campaign.organizer_quote || view_context.strip_tags(@campaign.description),
            image: @campaign.logo,
            url: @seller ? short_campaign_url(@campaign, seller: @seller.referral_code) : short_campaign_url(@campaign)
        }
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
        redirect_to(short_campaign_url(@campaign), flash: { warning: "抱歉，我们没有找到这个商品" }) and return unless @product && @product.collections.include?(@campaign.collection)

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
      
      if @order
        render text: 'fail' and return unless @order.status == 0 && @order.campaign_id == params[:item][:campaign_id].to_i
        
        @campaign = @order.campaign
      else
        @campaign = Campaign.active.where(:id=>params[:item][:campaign_id]).first
        
        render text: 'fail' and return unless @campaign
        
        @order = Order.create campaign_id: @campaign.id, delivery_method: (@campaign.delivery_type == 3 ? 1 : @campaign.delivery_type)
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
            render text: 'fail' and return unless @product && @product.collections.include?(@campaign.collection)
            
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
        
      access_token = session[:access_token]
      @nickname = session[:nickname].to_s
      
      session[:campaign_id] = @campaign.slug
      
      if params[:direct_donation]
        @order = Order.create campaign_id: @campaign.id, direct_donation: (params[:direct_donation].to_f * 100)
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
      
      # weixin_payment_init(@order.grandtotal)
      weixin_payment_init(1)
      weixin_address_init()
        
    end
    
    def weixin_payment_init(total_fee)
        
      r = Random.new
      num = r.rand(1000...9999)
      out_trade_no = DateTime.now.strftime("%Y%m%d%H%M%S") + num.to_s   #生产随机订单号，这里用当前时间加随机数，保证唯一
    
      if session[:openid]

        params = {
          body: '11号公益圈订单',
          out_trade_no: out_trade_no,
          # total_fee: 1,
          total_fee: total_fee,
          spbill_create_ip: '127.0.0.1',
          notify_url: root_url + 'weixin_custom/notify',
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

        end

      end
      
    end
    
    def weixin_address_init(access_token)
        
      @app_id = ENV["WEIXIN_APPID"]
      @timestamp = ""
      @nonceStr = ""
      @addrSign = ""
    
      @timestamp = Time.now.getutc.to_i.to_s
      @nonceStr = SecureRandom.uuid.tr('-', '')
      @absolute_url = request.original_url

      sign = "accesstoken=" + access_token.to_s + "&appid=" + @app_id.to_s + "&noncestr=" + @nonceStr.to_s + "&timestamp=" + @timestamp.to_s + "&url=" + @absolute_url.to_s

      require 'digest/sha1'
      @addrSign = Digest::SHA1.hexdigest(sign)
      
    end
    
    def ajax_update_order     
      
      order_make_anonymous = params[:order_make_anonymous]
      fullName = params[:fullName]
      provinceName = params[:provinceName]
      cityName = params[:cityName]
      cityAreaName = params[:cityAreaName]
      addressLine = params[:addressLine]
      receiveName = params[:receiveName]
      phoneNumber = params[:phoneNumber]
      zipCode = params[:zipCode]
      
      order = Order.find_by_id(params[:order_id])
      
      order.address_line_one = addressLine
      order.address_city = cityName
      order.address_state = provinceName
      order.address_postal_code = zipCode
      order.fullname = fullName
      order.phone_number = phoneNumber
      order.address_city_area = cityAreaName
      order.make_anonymous = order_make_anonymous
      
      order.status = 3
      order.save
      
      if session[:openid]
       
        $client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
        $client.send_text_custom(session[:openid], "支付成功！订单编号" + order.id.to_s.rjust(8,'0') + "。11号公益圈感谢您的支持！")
        
      end
      
      session[:confirm_order_id] = order.id
      session[:order_id] = nil
      
      render text: "success"
      
    end
    
    def show_confirmation
      if session[:confirm_order_id]
        @order = Order.find_by_id(session[:confirm_order_id])
        
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

        unless @order && @order.campaign_id == @campaign.id && @order.status == 0 && @order.valid_order?
          redirect_to(short_campaign_url(@campaign), flash: { warning: "无效订单" }) and return
        end

        @order.assign_attributes(order_params)

        if !@order.valid?
          message = ''
          @order.errors.each do |key, error|
            message = message + key.to_s.humanize + ' ' + error.to_s + ', '
          end
          redirect_to short_campaign_url(@campaign), flash: { danger: message[0...-2] } and return
        end

        # redirect_to(short_campaign_url(@campaign), flash: { warning: "Invalid order" }) and return unless params[:card_number] && params[:cvv] && params[:expiration_month] && params[:expiration_year]
         
        Stripe.api_key = Rails.configuration.stripe_api_key  
        
        response = PaymentApiResponse.new
        
        begin
          # if @campaign.organization.processor_id.present?
          #                 transaction[:service_fee_amount] = (@order.processing_fee_supporter + @order.processing_fee_organization)/100.0
          # end
          
          req = {
            :amount => @order.grandtotal.to_i,
            :currency => "usd",
            :description => "Raisy",
            :card => params[:stripe_token],
            :metadata => {
              :order_id => params[:order_id]
            }
          }
          
          stripe_hash = Stripe::Charge.create(req)
          
          response.success = true
          response.charge_id = stripe_hash[:id]
          response.card_type = stripe_hash[:source][:brand]
          response.card_last4 = stripe_hash[:source][:last4]
          response.card_expiration_month = stripe_hash[:source][:exp_month]
          response.card_expiration_year = stripe_hash[:source][:exp_year] 
        rescue => exception
            response.success = false
            response.message = exception.message
            
            logger.info exception.message
            redirect_to short_campaign_url(@campaign), flash: { warning: response.message } and return
        end

        if response.success?
            @order.status = 3
            @order.update_payment_api_data(response)
            @order.save
        else
            logger.info response.message
            redirect_to short_campaign_url(@campaign), flash: { warning: response.message } and return
        end

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

        session[:confirm_order_id] = @order.id
        session[:order_id] = nil

        if params[:order][:checkout_options]
            params[:order][:checkout_options].each do |option|
                cog = CheckoutOptionGroup.find_by_id(option[:checkout_option_group_id])
                if cog && option[:value].present?
                    if cog.is_dropdown?
                        property = cog.checkout_option_group_properties.find_by_id(option[:value])
                        @order.checkout_options.create(checkout_option_group_id: cog.id, value: property.value) if property
                    else
                        @order.checkout_options.create checkout_option_group_id: cog.id, value: option[:value]
                    end
                end
            end
        end

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
    end

    def order_params
        params.require(:order).permit :fullname, :email, :billing_zip_code, :address_fullname, :address_line_one, :address_line_two, :address_city,
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

end
