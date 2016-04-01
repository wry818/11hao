class ChairpersonDashboardController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  
    before_filter :authenticate_user!
    before_filter :load_organization, only: [:organization_details, :organization_deposit]
    before_filter :load_campaign, only: [:campaign, :campaign_details, :campaign_bulkshippinginfo, :campaign_sellers, :campaign_orders, :campaign_delivery, :campaign_orders_download, :campaign_contacts, :campaign_sendmails]
    before_filter :load_campaigns, only: [:campaign, :campaign_details, :campaign_sellers, :campaign_orders, :campaign_bulkshippinginfo, :campaign_contacts, :campaign_sendmails]
    
    def index
    end

    #ORGANIZATIONS
    def organizations
        @organizations = current_user.organizations.order(:id)
    end

    def organization_details
    end

    def organization_deposit
    end

    #CAMPAIGNS
    def campaigns
      @cp_param = params[:cp] || ""
      
      if @cp_param == ""
        @campaigns = current_user.campaigns.normal.select("id,title,slug,campaign_type,goal,end_date,logo").order(:id)
      else
        if sales_user? || crs_user? || admin_user?
          if sales_user?
            @organizations = current_user.organizations.active.select("id,name,address_city,address_state,entertainment_customer_id").order(:name).all
          end
        
          if crs_user? || admin_user?
            @organizations = Organization.active.select("id,name,address_city,address_state,entertainment_customer_id").order(:name).all
          end
        
          if params[:organization].present?
            ids = params[:organization].to_i
          
            @organization_id = ids
          else
            ids = @organizations.collect(&:id)
          
            @organization_id = 0
          end
        
          @campaigns = Campaign.normal.where(:organization_id=>ids).select(
                        "id,title,slug,campaign_type,goal,end_date").order(:id).all
        
          @total_orders = 0
          @total_sales = 0
        
          @campaigns.each do |campaign|
            @total_orders += campaign.completed
            @total_sales += campaign.saled
          end
        
          @organizations.each do |org|
            city = org.address_city || ""
            state = org.address_state || ""
          
            if city == ""
              addr = state
            else
              if state == ""
                addr = city
              else
                addr = city + ", " + state
              end
            end
          
            group_id = org.entertainment_customer_id || ""
          
            if addr == ""
              if group_id != ""
                addr = " ("  + group_id + ")"
              end
            else
              if group_id == ""
                addr = " ("  + addr + ")"
              else
                addr = " ("  + group_id + "-" + addr + ")"
              end
            end
          
            org.name = org.name + addr
          end
        else
          redirect_to root_path and return
        end
      end
    end
    
    def storefronts
      if sales_user? || crs_user? || admin_user?
        if sales_user?
          @organizations = current_user.organizations.active.select("id,name,address_city,address_state,entertainment_customer_id").order(:name).all
        end
        
        if crs_user? || admin_user?
          @organizations = Organization.active.select("id,name,address_city,address_state,entertainment_customer_id").order(:name).all
        end
        
        if params[:organization].present?
          ids = params[:organization].to_i
          
          @organization_id = ids
        else
          ids = @organizations.collect(&:id)
          
          @organization_id = 0
        end
        
        @campaigns = Campaign.storefronts.where(:organization_id=>ids).select(
                      "id,title,slug,campaign_type,goal,end_date").order(:id).all
        
        @total_orders = 0
        @total_sales = 0
        
        @campaigns.each do |campaign|
          @total_orders += campaign.completed
          @total_sales += campaign.saled
        end
        
        @organizations.each do |org|
          city = org.address_city || ""
          state = org.address_state || ""
          
          if city == ""
            addr = state
          else
            if state == ""
              addr = city
            else
              addr = city + ", " + state
            end
          end
          
          group_id = org.entertainment_customer_id || ""
          
          if addr == ""
            if group_id != ""
              addr = " ("  + group_id + ")"
            end
          else
            if group_id == ""
              addr = " ("  + addr + ")"
            else
              addr = " ("  + group_id + "-" + addr + ")"
            end
          end
          
          org.name = org.name + addr
        end
      else
        redirect_to root_path and return
      end
    end

    def campaign
    end

    def campaign_details
      @campaign_images = CampaignImage.default_images.order(:id).all
      @collections = Collection.isnot_destroy.active.order(:id)
      @show_congratulation = false
      
      if session[:congratulate_campaign_id] == @campaign.id && (session[:is_campaign_preview] || "") != "yes" && current_user && current_user.id == @campaign.organizer_id
        
        # Popup congratulation the first time chairperson visits the page
        session[:congratulate_campaign_id] = 0
        session[:is_campaign_preview] = ""
        
        @show_congratulation = true
      end
    end

    def campaign_sellers
        @sellers = @campaign.sellers
    end

    def campaign_orders
    end
    
    def campaign_order
      @order = Order.find_by_id(params[:order_id])
      @items = Item.where(:order_id=>params[:order_id]).order(:id).all
      @order_id = params[:order_id]
      @show_resend = @items.select{|x| x.delivery_method==1}.count>0
      
      render :partial=>"order_detail"
    end

    def campaign_delivery
    end
    
    def campaign_orders_download
      # see views/chairperson_dashboard/campaign_orders_download.xlsx.axlsx
      render xlsx: "campaign_orders_download", filename: "orders.xlsx"
    end

    def campaign_bulkshippinginfo
      if !crs_user? && !admin_user?
        redirect_to root_path and return
      end
      
      @campaign_bulkshippinginfo = @campaign.campaign_bulkshippinginfos.first
      @countries = Country.order(:id)
      @state_provinces = StateProvince.order(:id)
      
      if !@campaign_bulkshippinginfo
        @campaign_bulkshippinginfo = CampaignBulkshippinginfo.new
      end
    end
    
    def sales_report_content
      @report = params[:report] || ""
      
      if (admin_user? || sales_user? || crs_user?) && @report != ""
        org_ids = []
        
        if params[:organization].present?
          if admin_user? || crs_user?
              org_ids << params[:organization].to_i
          end
          
          if sales_user?
            org_ids = current_user.organizations.active.where(:id=>params[:organization].to_i).select("id").collect(&:id)
          end
        else
          if admin_user? || crs_user?
              org_ids = Organization.active.select("id").collect(&:id)
          end
          
          if sales_user?
            org_ids = current_user.organizations.active.select("id").collect(&:id)
          end
        end
        
        @campaigns = Campaign.where(:organization_id=>org_ids).select("id,slug").all
        
        if @report == "activity"
          @sellers = Seller.where(:campaign_id=>@campaigns.collect(&:id)).order(:campaign_id, :id).page(params[:page])
          # @sellers.each do |seller|
          #
          # end
          # @total_sales=@sellers.sum("total_sales")
          # @total_raised=Seller.where(:campaign_id=>@campaigns.collect(&:id)).sum("total_raised")

          logger.debug "1001"
          seller_ids=Seller.where(:campaign_id=>@campaigns.collect(&:id)).collect(&:id)
          orders=Order.where(:seller_id=>seller_ids).completed
          @total_orders_all=orders.count
          @total_sales_all=(orders.joins(:items).sum('items.quantity * (items.base_amount + items.donation_amount)') + orders.sum('direct_donation') )/ 100.0
          @total_raised_all= (orders.joins(:items).sum('items.quantity * items.donation_amount') + orders.sum('direct_donation') )/ 100.0

          user_profile_ids=Seller.where(:campaign_id=>@campaigns.collect(&:id)).collect(&:user_profile_id)
          user_ids=UserProfile.where(:id=>user_profile_ids).collect(&:user_id)
          @total_sigin_all=User.where(:id=>user_ids).sum("sign_in_count")

          render partial: "activities_report_content" and return
        end
        
        if @report == "sales"
          @orders = Order.completed.where(:campaign_id=>@campaigns.collect(&:id)).order(:id=>:desc).page(params[:page])

          orders=Order.completed.where(:campaign_id=>@campaigns.collect(&:id))
          @total_paid_all=0
          orders.each { |order| @total_paid_all+=order.grandtotal.to_f }
          render partial: "sales_report_content" and return
        end
      else
        render text: "" and return
      end
    end
    
    def sales_report
      if admin_user? || crs_user?
        @organizations = Organization.active.select("id,name,address_city,address_state,entertainment_customer_id").order(:name).all
      end
      
      if sales_user?
        @organizations = current_user.organizations.active.select("id,name,address_city,address_state,entertainment_customer_id").order(:name).all
      end
        
      if admin_user? || sales_user? || crs_user?
        if params[:organization].present?
          ids = params[:organization].to_i
          
          @organization_id = ids
        else
          ids = @organizations.collect(&:id)
          
          @organization_id = 0
        end
        
        @organizations.each do |org|
          city = org.address_city || ""
          state = org.address_state || ""
          
          if city == ""
            addr = state
          else
            if state == ""
              addr = city
            else
              addr = city + ", " + state
            end
          end
          
          group_id = org.entertainment_customer_id || ""
        
          if group_id == ""
              if addr != ""
                addr = " ("  + addr + ")"
              end
          else
            if addr == ""
                addr = " ("  + group_id + ")"
            else
                addr = " ("  + group_id + "-" + addr + ")"
            end
          end
          
          org.name = org.name + addr
        end
      end
    end
    
    def sales_report_download
      @report = params[:report] || ""
      
      if (admin_user? || sales_user? || crs_user?) && @report != ""
        org_ids = []
        
        if params[:organization].present?
          if admin_user? || crs_user?
              org_ids << params[:organization].to_i
          end
          
          if sales_user?
            org_ids = current_user.organizations.active.where(:id=>params[:organization].to_i).select("id").collect(&:id)
          end
        else
          if admin_user? || crs_user?
            org_ids = Organization.active.select("id").collect(&:id)
          end
          
          if sales_user?
            org_ids = current_user.organizations.active.select("id").collect(&:id)
          end
        end
        
        @campaigns = Campaign.where(:organization_id=>org_ids).select("id,slug").all
        
        if @report == "activity"
          @sellers = Seller.where(:campaign_id=>@campaigns.collect(&:id)).order(:campaign_id, :id)
          
          # see views/chairperson_dashboard/seller_activities_report_download.xlsx.axlsx
          render xlsx: "activities_report_download", filename: "activities_report.xlsx" and return
        end
        
        if @report == "sales"
          @orders = Order.completed.where(:campaign_id=>@campaigns.collect(&:id)).order(:id=>:desc)
          
          # see views/chairperson_dashboard/sales_report_download.xlsx.axlsx
          render xlsx: "sales_report_download", filename: "sales_report.xlsx" and return
        end
        
        render text: "" and return
      else
        render text: "" and return
      end
    end
    
    def campaign_contacts
      @contacts = current_user.contacts
      
      session[:contact_user_id] = current_user.id
    end
    
    def campaign_sendmails
      @email_msg = @campaign.email_text || ""
      
      # if @email_msg.nil?
      #     @email_msg = "<p>Please help us raise even more funds by joining the online fundraiser for "
      #     @email_msg += @campaign.title + ". "
      #     @email_msg += "It is simple and fun to set up your own personal fundraising page. "
      #     @email_msg += "Then, you can reach out to your supporters through email and social media "
      #     @email_msg += "and so they can purchase directly from your page, while you get credit!</p>"
      #     @email_msg += '<p>Click <a href="{{fundraiser.signup.url}}" target="_blank">this link</a> to get started.</p>'
      #     @email_msg += "<p>The SOONER you join, the MORE you can sell!</p>"
      # end
  
      if @email_msg != ""
        # {{fundraiser.title}} - Title of fundraiser
        # {{fundraiser.tagline}} - Tagline of fundraiser
        # {{fundraiser.goal}} - Goal of fundraiser
        # {{fundraiser.url}} - Url of fundraiser
        # {{fundraiser.chairperson}} - Title of fundraiser
        # {{fundraiser.signup.url}} - Url of seller signup
        # {{organization.name}} - Organization name
        # {{collection.name}} - Collection name
        # {{seller.fullname}} - Seller's fullname
        # {{seller.url}} - Url of seller's fundraiser page

        @email_msg = @email_msg.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
        @email_msg = @email_msg.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
        @email_msg = @email_msg.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
        @email_msg = @email_msg.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
        @email_msg = @email_msg.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
        @email_msg = @email_msg.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
        @email_msg = @email_msg.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
        @email_msg = @email_msg.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
        @email_msg = @email_msg.gsub(/\{\{seller\.fullname\}\}/, "")
        @email_msg = @email_msg.gsub(/\{\{seller\.url\}\}/, "")
      end
      
      @admin_setting = AdminSetting.first
      @default_email_msg = ""
      @default_email_msg_two = ""
      
      if @admin_setting
          @default_email_msg = @admin_setting.default_cp_email_message || ""
          
          if @default_email_msg != ""
              @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
              @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
              @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
              @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
              @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
              @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
              @default_email_msg = @default_email_msg.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
              @default_email_msg = @default_email_msg.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
              @default_email_msg = @default_email_msg.gsub(/\{\{seller\.fullname\}\}/, "")
              @default_email_msg = @default_email_msg.gsub(/\{\{seller\.url\}\}/, "")
              @default_email_msg = @default_email_msg.gsub(/\{\{contact\.greeting\}\}/, "")
          end
          
          @default_email_msg_two = @admin_setting.default_cp_email_message_two || ""
          
          if @default_email_msg != ""
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{seller\.fullname\}\}/, "")
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{seller\.url\}\}/, "")
              @default_email_msg_two = @default_email_msg_two.gsub(/\{\{contact\.greeting\}\}/, "")
          end
      end
    end
    
    private

    def load_organization
        @organization = Organization.friendly.find(params[:id])
    end

    def load_campaign
      begin
        @campaign = Campaign.friendly.find(params[:id])
        
        redirect_to root_url and return unless @campaign && (current_user.id == @campaign.organizer_id || admin_user? || sales_user? || crs_user?)
        url=Rails.configuration.url_host+campagin_ngo_campaignview_path("campaign_#{@campaign.id}")
        if Rails.env.test?||Rails.env.development?
          url=campagin_ngo_campaignview_url("campaign_#{@campaign.id}")
        end
        logger.debug url
        qr = RQRCode::QRCode.new(url, :size => 10, :level => :h)

        @qr_url = qr.to_img.resize(150, 150).to_data_url
      rescue
        redirect_to(root_url, flash: { warning: "抱歉，我们没有找到这个筹款团队！" }) and return
      end
    end
    
    def load_campaigns
      if sales_user?
        @organizations = current_user.organizations
        
        ids = @organizations.select(:id).collect(&:id)
        
        if @campaign.ent_campaign?
          @campaigns = Campaign.storefronts.where(:organization_id=>ids).select("id,title,slug").order(:id)
        else
          @campaigns = Campaign.normal.where(:organization_id=>ids).select("id,title,slug").order(:id)
        end
      else
        if crs_user? || admin_user?
          if @campaign.ent_campaign?
            @campaigns = Campaign.storefronts.select("id,title,slug").order(:id)
          else
            @campaigns = Campaign.normal.select("id,title,slug").order(:id)
          end
        else
          if @campaign.ent_campaign?
            @campaigns = current_user.campaigns.storefronts.select("id,title,slug").order(:id)
          else
            @campaigns = current_user.campaigns.normal.select("id,title,slug").order(:id)
          end
        end
      end
    end
end
