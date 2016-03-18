class CampaignsController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  
    before_filter :authenticate_user!, except: [:new, :campaign_account, :campaign_create_account, :get_organizations, :get_organization, :get_collections, :ajax_camp_step_popup]
    before_filter :load_campaign, only: [:campaign_preview, :campaign_contacts, :campaign_sendmails, :campaign_share]
    
    def campaign_account
      if current_user
        redirect_to new_campaign_path and return
      end
    end
    
    def campaign_create_account
      if current_user
        redirect_to new_campaign_path and return
      end
      
      is_raisy_user = params[:auth_provider] == "raisy"
      campaign_new_user = params[:campaign_new_user] == "1"
      is_valid_user = false
      
      if is_raisy_user
        oldUser = User.isnot_destroy.find_by email: params[:user]['email']
      else
        oldUser = User.find_by uid: params[:auth_uid], provider: params[:auth_provider]
      end
      
      if campaign_new_user
        # New user to create campaign
        if oldUser
          if is_raisy_user
            flash.now[:warning] = "抱歉，这个帐户已被注册。"
            render action: "campaign_account" and return
          else
            sign_in(oldUser)
          end
          
          profile = oldUser.profile
        else
          # Create a new user to be the organizer
          newUser = User.new
          newUser.email = params[:user][:email]
          newUser.password = params[:user][:password]
          newUser.password_confirmation = newUser.password
          newUser.provider = params[:auth_provider]
          
          if !is_raisy_user
            newUser.uid = params[:auth_uid]
          end
      
          unless newUser.save
            message = ''
            newUser.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "campaign_account" and return
          end
          
          profile = UserProfile.create user: newUser, first_name: params[:user][:first_name], last_name: params[:user][:last_name], phone_number: params[:user][:phone_number], child_profile: false

          sign_in(newUser)
        end
      else
        # Check existing user before creation
        if oldUser
          if is_raisy_user
            is_valid_user = oldUser.valid_password?(params[:user][:password])
          else
            is_valid_user = true
          end
        end
        
        if !is_valid_user
          flash.now[:danger] = "抱歉，您的邮箱或密码不正确。"
          render action: "campaign_account" and return
        end
        
        sign_in(oldUser)
        
        profile = oldUser.profile
      end
      
      redirect_to new_campaign_path and return
    end
    
    def new
      
      @campaign_mode = 1
      if params[:is_compassion].present?
        
        if params[:is_compassion].to_i > 0
          @campaign_mode = 2
        else
          @campaign_mode = 1
        end
        
      end
      
      if !current_user
        redirect_to campaign_account_path and return
      end
      
      @previous_url = request.referrer
      
      req_path = request.fullpath || ""
      
      if req_path.start_with?("/campaigns/account") || req_path.start_with?("/campaigns/create_account") || req_path.start_with?("/campaigns/new")
        @previous_url = root_path
      end
      
      if params[:collection]
          @collection = Collection.isnot_destroy.find_by_slug(params[:collection])
      end
      
      if !@collection
        @collections = Collection.isnot_destroy.active.order(:id)
      end
      
      @example_story_1 = CampaignStory.find_by_id(1)
      @example_story_2 = CampaignStory.find_by_id(2)
      @example_story_3 = CampaignStory.find_by_id(3)
      @example_story_4 = CampaignStory.find_by_id(4)
      @campaign_images = CampaignImage.default_images.order(:id).all
      @campaign = Campaign.new
      @campaign.description = @example_story_1.story
      @step_popup = session[:camp_step_popup] || "yes"
      
    end
    
    def get_organizations
      name = params[:name] || ""
      page = params[:page].to_i
      
      if name.present?
          query = "name ILIKE :search or address_city ILIKE :search or address_state ILIKE :search or entertainment_customer_id ILIKE :search"
          
          total = Organization.active.where(query, search: "%"+ name + "%").count
          
          orgs = Organization.active.where(query, search: "%"+ name + "%").select(
                  "id,name,address_city,address_state,entertainment_customer_id").limit(10).offset(10*(page-1)).order(:name)
          
      else
          total = Organization.active.count
          
          orgs = Organization.active.select("id,name,address_city,address_state,entertainment_customer_id").limit(10).offset(10*(page-1)).order(:name)
      end
      
      render json: orgs_to_json(orgs, total)
    end
    
    def get_organization
      org = Organization.find(params[:id])
      render json: {id: org.id, text: org.name, name: org.name}.to_json
    end
    
    def get_collections
      name = params[:name]
      page = params[:page].to_i
      
      total = Collection.isnot_destroy.where("active=true and upper(name) like ?", name.upcase + "%").count
      
      cols = Collection.isnot_destroy.where("active=true and upper(name) like ?", name.upcase + "%").limit(10).offset(10*(page-1)).order(:name)
      
      render json: cols_to_json(cols, total)
    end
    
    def ajax_create
      org = Organization.find_by_id(params[:organization_name])
    
      if !org
        render json: {}.to_json and return
      end
      
      @campaign = Campaign.find_by_id(params[:campaign_id])
      
      if @campaign
        if @campaign.organizer_id != current_user.id
          render json: {}.to_json and return
        end
        
        @campaign.assign_attributes campaign_params
      else
        @campaign = Campaign.new campaign_params
        
        @campaign.organizer = current_user
      end
      
      @campaign.organization_id = org.id
      
      if !@campaign.valid?
        render json: {}.to_json and return
      end
      
      if params[:campaign_logo].present?
          preloaded = Cloudinary::PreloadedFile.new(params[:campaign_logo])
          if preloaded.valid?
              @campaign.logo = preloaded.identifier
          end
      end
      
      @campaign.campaign_mode = params[:campaign_mode].to_i
      # @campaign.active = !@campaign.collection_id.nil?
      @campaign.active =true
      @campaign.save
      
      if preloaded
        res = Cloudinary::Api.resource(preloaded.public_id, :max_results=>0)
        
        campaignImage = @campaign.campaign_logo
        
        if !campaignImage
          campaignImage = CampaignImage.new
          campaignImage.campaign = @campaign
        end
        
        campaignImage.public_id = preloaded.public_id
        campaignImage.image_id = preloaded.identifier
        campaignImage.active = true
        campaignImage.image_identifier = params[:campaign_logo]
        campaignImage.is_logo = true
        campaignImage.image_width = res["width"]
        campaignImage.image_height = res["height"]
        campaignImage.crop_x = params[:logo_crop_x].to_i
        campaignImage.crop_y = params[:logo_crop_y].to_i
        campaignImage.crop_width = params[:logo_crop_w].to_i
        campaignImage.crop_height = params[:logo_crop_h].to_i
        campaignImage.is_cropped = true
        
        campaignImage.save
      end
      
      campaign_images = @campaign.campaign_images.all
      
      campaign_images.each do |image|
        image.active = false
      end
      
      if params[:campaign_photo_ids].present?
        params[:campaign_photo_ids].split(",").each do |id|
            if id != ""
              res = Cloudinary::Api.resource(id, :max_results=>0)
              
              cropX = 0
              cropY = 0
              cropW = res["width"]
              cropH = res["height"]
              cropped = false
          
              if params["crop_result_" + id].present?
                crop_result = JSON.parse(params["crop_result_" + id])
            
                if crop_result["stretch"]
                  cropped = false
                else
                  cropped = true
              
                  cropX = crop_result["cropX"]
                  cropY = crop_result["cropY"]
                  cropW = crop_result["cropW"]
                  cropH = crop_result["cropH"]
                end
              end
              
              campaignImage = campaign_images.select{|x| x.public_id==id}.first
             
              if campaignImage
                campaignImage.public_id = id
                campaignImage.image_id = id
                campaignImage.active = true
                campaignImage.image_identifier = id
                campaignImage.is_logo = false
                campaignImage.image_width = res["width"]
                campaignImage.image_height = res["height"]
                campaignImage.crop_x = cropX
                campaignImage.crop_y = cropY
                campaignImage.crop_width = cropW
                campaignImage.crop_height = cropH
                campaignImage.is_cropped = cropped
              else
                CampaignImage.create campaign: @campaign, public_id: id,
                  image_id: id, active: true, image_identifier: id,
                  is_logo: false, image_width: res["width"], image_height: res["height"],
                  crop_x: cropX, crop_y: cropY, crop_width: cropW, crop_height: cropH, is_cropped: cropped
              end
            end
        end
      end
      
      campaign_images.each do |image|
        image.save
      end
      
      render json: {id: @campaign.id, slug: @campaign.slug}.to_json and return
    end

    def create
      @campaign = Campaign.new campaign_params
      @collection = Collection.find_by_id(params[:campaign][:collection_id])
      @example_story_1 = CampaignStory.find_by_id(1)
      @example_story_2 = CampaignStory.find_by_id(2)
      @example_story_3 = CampaignStory.find_by_id(3)
      @example_story_4 = CampaignStory.find_by_id(4)
      @campaign_images = CampaignImage.default_images.order(:id).all
      @step_popup = session[:camp_step_popup] || "yes"
      
      if !@collection
        @collections = Collection.isnot_destroy.active.order(:id)
      end

      # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
      if !@campaign.valid?
          message = ''
          @campaign.errors.each do |key, error|
              message = message + key.to_s.humanize + ' ' + error.to_s + ', '
          end
          flash.now[:danger] = message[0...-2]
          render action: "new" and return
      end
      
      # organization_name actually saves organization id
      org = Organization.find_by_id(params[:organization_name])
      
      if !org
        flash.now[:danger] = "Please select an organization"
        render action: "new" and return
      end
      
      @campaign.organization = org
      @campaign.organizer = current_user
      
      if params[:campaign_logo].present?
          preloaded = Cloudinary::PreloadedFile.new(params[:campaign_logo])
          if preloaded.valid?
              @campaign.logo = preloaded.identifier
          end
      end

      @campaign.save
      
      if preloaded
        res = Cloudinary::Api.resource(preloaded.public_id, :max_results=>0)
        
        # Create a campaign_image as logo
        CampaignImage.create campaign: @campaign, public_id: preloaded.public_id,
          image_id: preloaded.identifier, active: true, image_identifier: params[:campaign_logo],
          is_logo: true, image_width: res["width"], image_height: res["height"], 
          crop_x: params[:logo_crop_x].to_i, crop_y: params[:logo_crop_y].to_i, 
          crop_width: params[:logo_crop_w].to_i, crop_height: params[:logo_crop_h].to_i, 
          is_cropped: true
      end
      
      # More campaign photos
      if params[:campaign_photo_ids].present?
        params[:campaign_photo_ids].split(",").each do |id|
            if id != ""
              res = Cloudinary::Api.resource(id, :max_results=>0)
              
              cropX = 0
              cropY = 0
              cropW = res["width"]
              cropH = res["height"]
              cropped = false
              
              if params["crop_result_" + id].present?
                crop_result = JSON.parse(params["crop_result_" + id])
                
                if crop_result["stretch"]
                  cropped = false
                else
                  cropped = true
                  
                  cropX = crop_result["cropX"]
                  cropY = crop_result["cropY"]
                  cropW = crop_result["cropW"]
                  cropH = crop_result["cropH"]
                end
              end
              
              # Create a campaign_image as photo
              CampaignImage.create campaign: @campaign, public_id: id,
                image_id: id, active: true, image_identifier: id,
                is_logo: false, image_width: res["width"], image_height: res["height"], 
                crop_x: cropX, crop_y: cropY, crop_width: cropW, crop_height: cropH, is_cropped: cropped
            end
        end
      end
      
      session[:congratulate_campaign_id] = @campaign.id

      redirect_to campaign_preview_path(@campaign) and return
    end

    def update
        @campaign = Campaign.friendly.find(params[:id])
        @campaign.assign_attributes campaign_params
        
        @campaign_images = CampaignImage.default_images.order(:id).all
        @collections = Collection.isnot_destroy.active.order(:id)
        @show_congratulation = false
      
        if session[:congratulate_campaign_id] == @campaign.id && (session[:is_campaign_preview] || "") != "yes" && current_user && current_user.id == @campaign.organizer_id
        
          # Popup congratulation the first time chairperson visits the page
          session[:congratulate_campaign_id] = 0
          session[:is_campaign_preview] = ""
        
          @show_congratulation = true
        end

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@campaign.valid?
            message = ''
            @campaign.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render 'chairperson_dashboard/campaign_details' and return
        end

        @campaign.save

        if params[:campaign_logo].present?
            preloaded = Cloudinary::PreloadedFile.new(params[:campaign_logo])
            
            if preloaded.valid?
                res = Cloudinary::Api.resource(preloaded.public_id, :max_results=>0)
                
                @campaign.update_attribute(:logo, preloaded.identifier)
                
                campaignImage = @campaign.campaign_logo
                
                if campaignImage
                else
                  campaignImage = CampaignImage.new
                  campaignImage.campaign = @campaign
                end
                
                campaignImage.public_id = preloaded.public_id
                campaignImage.image_id = preloaded.identifier
                campaignImage.active = true
                campaignImage.image_identifier = params[:campaign_logo]
                campaignImage.is_logo = true
                campaignImage.image_width = res["width"]
                campaignImage.image_height = res["height"]
                campaignImage.crop_x = params[:logo_crop_x].to_i
                campaignImage.crop_y = params[:logo_crop_y].to_i
                campaignImage.crop_width = params[:logo_crop_w].to_i
                campaignImage.crop_height = params[:logo_crop_h].to_i
                campaignImage.is_cropped = true
                
                campaignImage.save
            end
        end
        
        # Deal with campaign photos
        if params[:campaign_photo_ids].present?
          @campaign.campaign_images.each do |image|
            image.active = false
            image.save
          end
          
          params[:campaign_photo_ids].split(",").each do |id|
              if id != ""
                campaignImage = @campaign.campaign_images.where(:public_id=>id).first
              
                if campaignImage
                  campaignImage.active = true
                  campaignImage.save
                else
                  res = Cloudinary::Api.resource(id, :max_results=>0)
                  
                  cropX = 0
                  cropY = 0
                  cropW = res["width"]
                  cropH = res["height"]
                  cropped = false
              
                  if params["crop_result_" + id].present?
                    crop_result = JSON.parse(params["crop_result_" + id])
                
                    if crop_result["stretch"]
                      cropped = false
                    else
                      cropped = true
                  
                      cropX = crop_result["cropX"]
                      cropY = crop_result["cropY"]
                      cropW = crop_result["cropW"]
                      cropH = crop_result["cropH"]
                    end
                  end
        
                  # Create a campaign_image as photo
                  CampaignImage.create campaign: @campaign, public_id: id,
                    image_id: id, active: true, image_identifier: id,
                    is_logo: false, image_width: res["width"], image_height: res["height"],
                    crop_x: cropX, crop_y: cropY, crop_width: cropW, crop_height: cropH, is_cropped: cropped
                end
              end
          end
        end

        redirect_to(dashboard_campaign_details_url(@campaign), flash: { success: "保存成功" }) and return
    end

    def update_delivery
        @campaign = Campaign.friendly.find(params[:id])
        @campaign.assign_attributes campaign_delivery_params

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@campaign.valid?
            message = ''
            @campaign.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render 'chairperson_dashboard/campaign_delivery' and return
        end

        @campaign.save

        redirect_to(dashboard_campaign_delivery_url(@campaign), flash: { success: "Delivery options updated!" }) and return
    end

    def create_bulkshippinginfo
        @campaign = Campaign.friendly.find(params[:id])
        @campaign_bulkshippinginfo = @campaign.campaign_bulkshippinginfos.first
        
        if !@campaign_bulkshippinginfo
          
          @campaign_bulkshippinginfo = CampaignBulkshippinginfo.new  campaign_bulkshippinginfo_params
          @campaign_bulkshippinginfo.campaign_id = @campaign.id
          
          if campaign_bulkshippinginfo_params[:delivery_date].blank?
            @campaign_bulkshippinginfo.delivery_datetime = nil
          else
            if campaign_bulkshippinginfo_params[:delivery_time].blank?
              @campaign_bulkshippinginfo.delivery_datetime = campaign_bulkshippinginfo_params[:delivery_date]
            else
              @campaign_bulkshippinginfo.delivery_datetime = campaign_bulkshippinginfo_params[:delivery_date] + " " + campaign_bulkshippinginfo_params[:delivery_time]
            end
          end
          
          @campaign_bulkshippinginfo.save
        
        end
        
        if params[:bulk_submit_order]=="1"
          @campaign.is_bulk_submitted=true
          @campaign.bulk_submitted_at=DateTime.now
          @campaign.save
          
          redirect_to(dashboard_campaign_bulkshippinginfo_url(@campaign), flash: { success: "Order has been submitted!" }) and return
        else
          redirect_to(dashboard_campaign_bulkshippinginfo_url(@campaign), flash: { success: "Information updated!" }) and return
        end
    end
    
    def update_bulkshippinginfo
      
      @campaign_bulkshippinginfo = CampaignBulkshippinginfo.find(params[:id])
      @campaign = @campaign_bulkshippinginfo.campaign
      
      @campaign_bulkshippinginfo.assign_attributes campaign_bulkshippinginfo_params
      
      if campaign_bulkshippinginfo_params[:delivery_date].blank?
        @campaign_bulkshippinginfo.delivery_datetime = nil
      else
        if campaign_bulkshippinginfo_params[:delivery_time].blank?
          @campaign_bulkshippinginfo.delivery_datetime = campaign_bulkshippinginfo_params[:delivery_date]
        else
          @campaign_bulkshippinginfo.delivery_datetime = campaign_bulkshippinginfo_params[:delivery_date] + " " + campaign_bulkshippinginfo_params[:delivery_time]
        end
      end
      
      @campaign_bulkshippinginfo.save
      
      if params[:bulk_submit_order]=="1"
        @campaign.is_bulk_submitted=true
        @campaign.bulk_submitted_at=DateTime.now
        @campaign.save
        
        redirect_to(dashboard_campaign_bulkshippinginfo_url(@campaign), flash: { success: "Order has been submitted!" }) and return
      else
        redirect_to(dashboard_campaign_bulkshippinginfo_url(@campaign), flash: { success: "Information updated!" }) and return
      end
    end
    
    def campaign_preview
      session[:is_campaign_preview] = "yes"
      
      @step_popup = session[:camp_step_popup] || "yes"
      
      qr = RQRCode::QRCode.new(Rails.configuration.url_host + short_campaign_path(@campaign), :size => 10, :level => :h)

      @qr_url = qr.to_img.resize(200, 200).to_data_url
    end
    
    def campaign_contacts
      @contacts = current_user.contacts
      
      session[:contact_user_id] = current_user.id
      
      @step_popup = session[:camp_step_popup] || "yes"
      
      session[:is_campaign_preview] = ""
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
        # {{fundraiser.chairperson}} - CP of fundraiser
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
      
      @step_popup = session[:camp_step_popup] || "yes"
      
      session[:is_campaign_preview] = ""
    end
    
    def campaign_share
      session[:is_campaign_preview] = ""
    end
    
    def ajax_camp_step_popup
        begin
          popup = params[:popup]
          
          if popup == "disable"
              session[:camp_step_popup] = "no"
          end
                  
          render text: session[:camp_step_popup] || "yes"
        rescue => exception
          logger.info exception.message
          render text: session[:camp_step_popup] || "yes"
        end
    end
    
    private
    # Using a private method to encapsulate the permissible parameters is
    # just a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def campaign_params
        params.require(:campaign).permit :minilogo,:is_featured,:receiver, :title, :organizer_quote, :campaign_mode, :goal, :seller_goal, :seller_compassion_goal, :display_seller_goal, :end_date, :organizer_quote, :description, :collection_id, :call_to_action, :allow_direct_donation, :active
    end

    def campaign_delivery_params
        params.require(:campaign).permit :has_pickup, :pickup_instructions, :has_shipping, :shipping_instructions,
                                                              :shipping_flat_rate, :digital_delivery_instructions
    end
    
    def campaign_bulkshippinginfo_params
        params.require(:campaign_bulkshippinginfo).permit :ship_to_name, :ship_to_attn, :address_line_1, :address_line_2, 
                          :city, :state_province_id, :zip_code, :country_id, :phone_number,
                         :email_address, :delivery_date, :delivery_time, :delivery_datetime
    end
    
    def load_campaign
      begin
        @campaign = Campaign.friendly.find(params[:id])
        
        if current_user.id != @campaign.organizer_id
          redirect_to root_path and return
        end
      rescue
        redirect_to(root_url, flash: { warning: "抱歉，我们没有找到这个筹款团队！" }) and return
      end
    end
    
    def orgs_to_json(orgs, total)
      Jbuilder.encode do |json|        
        json.orgs orgs do |org|
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
          
          json.id org.id
          json.text org.name + addr
          json.name org.name
        end
        
        json.total total
      end
    end
    
    def cols_to_json(cols, total)
      Jbuilder.encode do |json|
        json.cols cols do |col|
          json.id col.id
          json.text col.name
        end
        
        json.total total
      end
    end
end
