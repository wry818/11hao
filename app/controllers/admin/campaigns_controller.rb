class Admin::CampaignsController < Admin::ApplicationController
    def index
        @campaigns = Campaign.order(:id)

        @campaigns = Campaign.isnot_destroy.order(:id)
    end

    def new
        @campaign = Campaign.new
        @collections = Collection.isnot_destroy.where("id>0").order(:id)
        @users = User.isnot_destroy.where(:is_fake=>false).order(:id)
        @campaign_images = CampaignImage.default_images.order(:id).all
        
        if params[:organization].present?
          @target_organization = Organization.find_by_id(params[:organization])
          
          if @target_organization
            @campaign.title = @target_organization.name
            @campaign.campaign_type = 2
            @campaign.organization_id = @target_organization.id
            
            session[:target_organization_id] = @target_organization.id
          end
        else
          session[:target_organization_id] = nil
        end
    end

    def edit
        @campaign = Campaign.friendly.find(params[:id])
        @collections = Collection.isnot_destroy.where("id>0").order(:id)
        @users = User.isnot_destroy.where(:is_fake=>false).order(:id)
        @campaign_images = CampaignImage.default_images.order(:id).all
        
        if params[:organization].present?
          @target_organization = Organization.find_by_id(params[:organization])
          
          if @target_organization
            session[:target_organization_id] = @target_organization.id
          end
        else
          session[:target_organization_id] = nil
        end
    end
    
    def create
        @campaign = Campaign.new campaign_params
        @collections = Collection.isnot_destroy.where("id>0").order(:id)
        @users = User.isnot_destroy.where(:is_fake=>false).order(:id)
        @collection = Collection.find_by_id(params[:campaign][:collection_id])
        @campaign_images = CampaignImage.default_images.order(:id).all

        # session[:target_organization_id]=params[:organization_name]

        if session[:target_organization_id]
          @target_organization = Organization.find_by_id(session[:target_organization_id])
          
          if @target_organization
            @campaign.campaign_type = 2
            @campaign.organization_id = @target_organization.id
            
            campaign = Campaign.storefronts.where(entertainment_group_id: @target_organization.entertainment_customer_id).first
            
            if campaign
              flash.now[:danger] = "抱歉，" + @target_organization.name + "组织店面已经存在了"
              render action: "new" and return
            end
          end
        end
        
        campaign_title = @campaign.title
        
        if @target_organization
          # Make group code as slug
          @campaign.title = @target_organization.entertainment_customer_id
          @campaign.entertainment_group_id = @target_organization.entertainment_customer_id
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
          flash.now[:danger] = "请选择组织"
          render action: "new" and return
        end
      
        @campaign.organization = org
        
        if params[:campaign_logo].present?
            preloaded = Cloudinary::PreloadedFile.new(params[:campaign_logo])
            if preloaded.valid?
                @campaign.update_attribute(:logo, preloaded.identifier)
            end
        end
        
        if org
          # Change title back to origin
          @campaign.title = campaign_title
          @campaign.save
        end
        
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
        
        if session[:target_organization_id]
          organization = Organization.find_by_id(session[:target_organization_id])
          
          session[:target_organization_id] = nil
          
          if organization
            redirect_to edit_admin_organization_path(organization) and return 
          end
        end
         
        redirect_to admin_campaigns_path and return 
    end

    def destroy
     campaign = Campaign.find(params[:id])
      # campaign.is_destroy=true;
      campaign.update(is_destroy:true)

      # render text: @campaign.to_yaml
      redirect_to admin_campaigns_path, flash: { success: "筹款团队刪除成功" }
    end

    def update
        @campaign = Campaign.friendly.find(params[:id])
        @campaign.assign_attributes campaign_params
        @users = User.isnot_destroy.where(:is_fake=>false).order(:id)
        @collections = Collection.where("id>0").order(:id)
        @collection = Collection.find_by_id(params[:campaign][:collection_id])
        @campaign_images = CampaignImage.default_images.order(:id).all
        
        if session[:target_organization_id]
          @target_organization = Organization.find_by_id(session[:target_organization_id])
          
          if @target_organization && (!@campaign.ent_campaign? || @target_organization.id != @campaign.organization.id)
            flash.now[:danger] = "抱歉，这个不是" + @target_organization.name + "店面"
            render action: "edit" and return
          end
        end

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@campaign.valid?
            message = ''
            @campaign.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "edit" and return
        end

        # organization_name actually saves organization id
        org = Organization.find_by_id(params[:organization_name])
        
        if !org
          flash.now[:danger] = "请选择一个组织"
          render action: "edit" and return
        end
        
        if @target_organization
          if @target_organization.id != org.id
            flash.now[:danger] = "抱歉，组织的店面不能被修改"
            render action: "edit" and return
          end
        end
      
        @campaign.organization = org
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
        
        if session[:target_organization_id]
          organization = Organization.find_by_id(session[:target_organization_id])
          
          session[:target_organization_id] = nil
          
          if organization
            redirect_to edit_admin_organization_path(organization) and return 
          end
        end
        
        redirect_to(admin_campaigns_path) and return
    end
    
    def stories
      @stories=CampaignStory.order(:id)
    end
    
    def story
      @story = CampaignStory.find_by_id(params[:id])
    end
    
    def save_story
      if params[:story_id].present? and params[:story].present? and params[:title].present?
        story = CampaignStory.find_by_id(params[:story_id])
      
        if story
          story.title=params[:title]
          story.story=params[:story]
          story.save
        end
      end
      
      redirect_to("/admin/campaign_stories") and return
    end
    
    def images
      @images=CampaignImage.default_images.order(:id)
    end
    
    def image
      
    end
    
    def save_image
      if params[:campaign_image].present?
        preloaded = Cloudinary::PreloadedFile.new(params[:campaign_image])
        if preloaded.valid?
          res = Cloudinary::Api.resource(preloaded.public_id, :max_results=>0)
          
          image = CampaignImage.new
          
          image.public_id = preloaded.public_id
          
          # used to load image
          image.image_id = preloaded.identifier 
          
           # used to verify the image when passed into Cloudinary::PreloadedFile.new
          image.image_identifier = params[:campaign_image]
          
          image.image_width = res["width"]
          image.image_height = res["height"]
          image.crop_x = params[:logo_crop_x].to_i
          image.crop_y = params[:logo_crop_y].to_i
          image.crop_width = params[:logo_crop_w].to_i
          image.crop_height = params[:logo_crop_h].to_i
          image.is_cropped = true
          image.active = true
          image.save
        end
      end
      
      redirect_to("/admin/campaign_images") and return
    end
    
    def delete_image
      json='{"result":false}'
      
      if params[:id].present?
        image = CampaignImage.find_by_id(params[:id])

        if image
          image.active=false
          image.save

          json='{"result":true}'
        end
      end
      
      render json: json
    end

    def bulkshippinginfo
      
      @campaign = Campaign.friendly.find(params[:id])
      @campaign_bulkshippinginfo = @campaign.campaign_bulkshippinginfos.first
      @countries = Country.order(:id)
      @state_provinces = StateProvince.order(:id)
      
      if !@campaign_bulkshippinginfo
        @campaign_bulkshippinginfo = CampaignBulkshippinginfo.new
      end
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

          redirect_to(admin_campaign_bulkshippinginfo_url(@campaign), flash: { success: "订单已提交" }) and return
        else
          redirect_to(admin_campaign_bulkshippinginfo_url(@campaign), flash: { success: "信息已保存" }) and return
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

        redirect_to(admin_campaign_bulkshippinginfo_url(@campaign), flash: { success: "订单已提交" }) and return
      else
        redirect_to(admin_campaign_bulkshippinginfo_url(@campaign), flash: { success: "信息已保存" }) and return
      end

    end
    
    private

    def campaign_params
        params.require(:campaign).permit :title, :organizer_quote, :campaign_mode, :goal, :seller_goal, :seller_compassion_goal, :display_seller_goal, :end_date, :organizer_quote, 
            :description, :collection_id, :call_to_action, :organizer_id, :allow_direct_donation,
            :discount, :purchase_limit, :active
    end

    def campaign_delivery_params
        params.require(:campaign).permit :has_pickup, :pickup_instructions, :has_shipping, 
            :shipping_instructions,:shipping_flat_rate, :digital_delivery_instructions
    end

    def campaign_bulkshippinginfo_params
        params.require(:campaign_bulkshippinginfo).permit :ship_to_name, :ship_to_attn, 
            :address_line_1, :address_line_2, 
            :city, :state_province_id, :zip_code, :country_id, :phone_number,
            :email_address, :delivery_date, :delivery_time, :delivery_datetime
    end
    
end
