class UsersController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  
    before_filter :authenticate_user!, 
      except: [:show, :new, :create, :signup_seller, :signup_seller_create, :signup_seller_weixin, :signup_seller_weixin_create,  
        :omniauth_callback, :omniauth_failure, 
        :verify_user, :lookup_user, :ajax_seller_step_popup]

    def show
        @user = User.friendly.find(params[:id])
    end

    def new
        @user = User.new
        session[:landing] = params[:landing]
    end

    def create
        @user = User.new user_params
        @user.password_confirmation = @user.password
        @user.provider = "raisy"

        unless @user.save
            message = ''
            @user.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]            
            redirect_to new_user_registration_path, :flash => { :danger => message[0...-2] } and return
        end

        sign_in(@user)

        UserProfile.create user: @user, first_name: params[:first_name], last_name: params[:last_name], child_profile: false

        if session[:landing]
            redirect_to session[:landing]
            session[:landing] = nil and return
        else
            redirect_to root_url and return
        end
    end
    
    def verify_user
      user = User.find_by email: URI.unescape(params[:email].downcase)
      
      if user
        is_valid = user.valid_password?(URI.unescape(params[:password]))
        
        render json: {verified: is_valid}.to_json 
      else
        render json: {verified: false}.to_json
      end
    end
    
    def lookup_user
      user = User.find_by email: URI.unescape(params[:email])
      
      if user
        render json: {user: {email: user.email, uid: user.uid || "", provider: user.provider || "raisy"}}.to_json 
      else
        render json: {user: nil}.to_json
      end
    end

    def signup_seller
        @campaign = Campaign.friendly.find(params[:campaign_id])
        if current_user && current_user.account_type == 3
          @existing_seller_profiles = current_user.child_profiles
          
          #@existing_seller_profiles = current_user.child_profiles.where.not(id: @campaign.sellers.map(&:user_profile_id))
        end
        
        @step_popup = session[:seller_step_popup] || "yes"
        
        render "signup_seller_new"
    end

    def signup_seller_create

        @campaign = Campaign.friendly.find(params[:campaign_id])
        @account_type = params[:user]['account_type'].to_i

        user = params[:user]
        parent = params[:parent]
        seller1314 = params[:seller1314]
        seller18 = params[:seller18]
        is_current_user = false
        
        @step_popup = session[:seller_step_popup] || "yes"
        
        if current_user
          is_current_user = true
          
          current_user.account_type = @account_type
          current_user.save
          
          @user = current_user
        else
          @user = User.new
          @user.password = user['password']
          @user.email = user['email']
          @user.account_type = @account_type
          
          if params[:auth_uid].present?
            @user.uid = params[:auth_uid]
          end
          
          @user.provider = params[:auth_provider]

          #save user
          unless @user.save
              message = ''
              @user.errors.each do |key, error|
                  message = message + key.to_s.humanize + ' ' + error.to_s + ', '
              end
              flash.now[:danger] = message[0...-2]
              render action: "signup_seller_new" and return
          end
        end
        
        if @account_type == 1 #seller is 18+
          sellerProfile = @user.profile
          
          if !sellerProfile
            #save profile
            sellerProfile = UserProfile.create user: @user, first_name: seller18['first_name'], last_name: seller18['last_name'], child_profile: false
            
            # Save user's social image
            if params[:auth_uimage].present?
              begin
                image_hash=Cloudinary::Uploader.upload(params[:auth_uimage], :tags => "social-user-image")
              rescue
              ensure
              end

              if image_hash
                sellerProfile.picture = image_hash["public_id"]
                sellerProfile.save
              end
            end
          end
          
          if @user.is_seller?(@campaign)
            sign_in(@user)
            
            redirect_to seller_dashboard_referral_code_url(@user.profile.seller(@campaign).referral_code), flash: { success: "您已加入此筹款团队!" } and return
          end
          
          #save seller
          sellerSeller = Seller.create user_profile: sellerProfile, campaign: @campaign

          #Send a reg email
          begin
              UserMailer.registration(sellerSeller,@campaign).deliver
          rescue => exception
              logger.info exception.message
          end

          sign_in(@user)

          redirect_to seller_photo_path(sellerSeller) and return
          
        elsif @account_type == 2 #seller is 14-17
          childProfile = @user.profile
          
          if !childProfile
            #save profile
            childProfile = UserProfile.create user: @user, first_name: seller1314['first_name'], last_name: seller1314['last_name'], parent_first_name: parent['first_name'], parent_last_name: parent['last_name'], parent_email: parent['email'], child_profile: false
          
            # Save user's social image
            if params[:auth_uimage].present?
              begin
                image_hash=Cloudinary::Uploader.upload(params[:auth_uimage], :tags => "social-user-image")
              rescue
              ensure
              end

              if image_hash
                childProfile.picture = image_hash["public_id"]
                childProfile.save
              end
            end
          end
          
          if @user.is_seller?(@campaign)
            sign_in(@user)
            
            redirect_to seller_dashboard_referral_code_url(@user.profile.seller(@campaign).referral_code), flash: { success: "您已加入此筹款团队!" } and return
          end
          
          #save seller
          childSeller = Seller.create user_profile: childProfile, campaign: @campaign, grade: seller1314['grade'], homeroom: seller1314['homeroom']

          #Send a reg email
          begin
              UserMailer.registration(childSeller,@campaign).deliver
          rescue => exception
              logger.info exception.message
          end

          #Send a parentnotify email
          begin
              UserMailer.parentnotifywith14oldseller(childSeller,@campaign,childProfile).deliver
          rescue => exception
              logger.info exception.message
          end

          sign_in(@user)

          redirect_to seller_photo_path(childSeller) and return
          
        elsif @account_type == 3 #seller is 13
          profile = @user.profile
          
          if !profile 
            #save profile
            profile = UserProfile.create user: @user, first_name: parent['first_name'], last_name: parent['last_name'], parent_email: parent['email'], child_profile: false
          
            # Save user's social image
            if params[:auth_uimage].present?
              begin
                image_hash=Cloudinary::Uploader.upload(params[:auth_uimage], :tags => "social-user-image")
              rescue
              ensure
              end

              if image_hash
                profile.picture = image_hash["public_id"]
                profile.save
              end
            end
          end
          
          childProfile = UserProfile.create user: @user, first_name: seller1314['first_name'], last_name: seller1314['last_name'], child_profile: true

          #save seller
          childSeller = Seller.create user_profile: childProfile, campaign: @campaign, grade: seller1314['grade'], homeroom: seller1314['homeroom']

          #Send a parentnotify email
          begin
              UserMailer.parentnotifywith13oldseller(childSeller,@campaign,profile).deliver
          rescue => exception
              logger.info exception.message
          end

          sign_in(@user)
          
          redirect_to seller_photo_path(childSeller) and return
        end

    end

    def signup_seller_add
        campaign = Campaign.friendly.find(params[:campaign_id])
        sellertype = params[:post_seller_type]
        sellerexist = params[:sellerexist]
        sellernew = params[:seller]
        
        if sellertype == "1"  #update seller when choose existing seller from your account

            existing_seller_profile = current_user.child_profiles.where(id: params[:existing_seller_profile][:id]).first
            
            seller = existing_seller_profile.seller(campaign)
            
            if seller
              redirect_to seller_dashboard_referral_code_url(seller.referral_code), flash: { success: "您已加入此筹款团队!" } and return
            else
              seller = Seller.create user_profile: existing_seller_profile, campaign: campaign, grade: sellerexist['grade'], homeroom: sellerexist['homeroom']
            end

            #TODO: Add an email in here that confirms the seller was added to a new campaign?

        elsif sellertype == "2"  #add new seller when choose create new one.

           profile = UserProfile.create user: current_user, first_name: sellernew['first_name'], last_name: sellernew['last_name'], child_profile: true
           seller = Seller.create user_profile: profile, campaign: campaign, grade: sellernew['grade'], homeroom: sellernew['homeroom']

           #TODO: Add an email in here that confirms the new seller was added to the account?

        else  #add new seller when user logged in and this user's account type is 1 or 2
     
            seller = current_user.profile.seller(campaign)
            
            if seller
              redirect_to seller_dashboard_referral_code_url(seller.referral_code), flash: { success: "您已加入此筹款团队!" } and return
            else
              seller = Seller.create user_profile: current_user.profile, campaign: campaign, grade: sellernew['grade'], homeroom: sellernew['homeroom']
            end
          
            #TODO: Add an email in here that confirms the new campaign this seller has joined?

        end

        redirect_to seller_photo_path(seller) and return

    end
    
    def signup_seller_weixin
      begin
        @campaign = Campaign.friendly.find(params[:campaign_id])
        
        @file_name = params[:video_file_name] + ".mp4"
        @nick_name = ""
        @avatar_url = ""

        user_info = ApiWeixinHelper.get_user_info(session[:openid], session[:access_token])

        if user_info
          @nick_name = user_info.result["nickname"]
          @avatar_url = user_info.result["headimgurl"]
        else
          # redirect_to root_path and return
        end
      rescue => ex
        redirect_to root_path and return
      end
    end
    
    def signup_seller_weixin_create
      begin
        @campaign = Campaign.find_by_id(params[:campaign_id])
        
        if !@campaign
          redirect_to root_path and return
        end
        
        @file_name = params[:video_file_name]
        @nick_name = ""
        @avatar_url = ""

        user_info = ApiWeixinHelper.get_user_info(session[:openid], session[:access_token])

        if user_info
          @nick_name = user_info.result["nickname"]
          @avatar_url = user_info.result["headimgurl"]
          @nick_name = params[:nickname] if params[:nickname].present?
          @user = User.find_by uid: session[:openid], provider: "wx"
          
          if !@user
            @user = User.new
            @user.password = "temp1234"
            @user.email = SecureRandom.hex(2) + Time.now.to_i.to_s + "@11hao.com"
            @user.account_type = 1
            @user.uid = session[:openid]
            @user.provider = "wx"
            
            unless @user.save
              redirect_to root_path and return
            end
          end
          
          @user_profile = @user.profile
          
          if !@user_profile
            @user_profile = UserProfile.create user: @user, first_name: @nick_name, child_profile: false
          end
          
          if params[:user_picture].present?
              preloaded = Cloudinary::PreloadedFile.new(params[:user_picture])
              if preloaded.valid?
                  @user_profile.update_attribute(:picture, preloaded.identifier)
              end
          else
              if params[:use_photo].present?
                # Use default photo, so upload the url passed in to cloud
                # Note: it does not work on localhost since the url is not public
              
                image_hash = Cloudinary::Uploader.upload(params[:use_photo], :tags => "custom-user-photo")

                @user_profile.update_attribute(:picture, image_hash["public_id"])
              end
          end
          
          @seller = @user_profile.seller(@campaign)
          
          if @seller
            @seller.video_file = params[:video_file]
            @seller.save
          else
            @seller = Seller.create user_profile: @user_profile, campaign: @campaign, video_file: params[:video_file]
          end
          
          redirect_to short_campaign_path(@campaign, seller: @seller.referral_code), flash: { success: "您已加入此筹款团队!" } and return
        else
          redirect_to root_path and return
        end
      rescue => ex
        redirect_to root_path and return
      end
    end
    
    def seller_photo
      @seller = Seller.find_by_id(params[:seller_id])
      
      if @seller
        @campaign = @seller.campaign
        
        if !current_user.is_seller?(@campaign)
          redirect_to root_path and return
        end
        
        @step_popup = session[:seller_step_popup] || "yes"
      else
        redirect_to root_path and return
      end   
    end
    
    def update_seller_photo
      @seller = Seller.find_by_id(params[:seller_id])
      
      if @seller
        @campaign = @seller.campaign
        
        if !current_user.is_seller?(@campaign)
          redirect_to root_path and return
        end
        
        @user_profile = @seller.user_profile.user.profile
      
        if params[:user_picture].present?
            preloaded = Cloudinary::PreloadedFile.new(params[:user_picture])
            if preloaded.valid?
                @user_profile.update_attribute(:picture, preloaded.identifier)
            end
        else
            if params[:use_photo].present?
              # Use default photo, so upload the url passed in to cloud
              # Note: it does not work on localhost since the url is not public
              
              image_hash = Cloudinary::Uploader.upload(params[:use_photo], :tags => "custom-user-photo")

              @user_profile.update_attribute(:picture, image_hash["public_id"])
            end
        end
      
        # redirect_to seller_get_contacts_path(@seller)
        redirect_to signup_seller_share_path(@seller)
      else
        redirect_to root_path and return
      end   
    end
    
    def seller_contacts
      @seller = Seller.find_by_id(params[:id]) 
      
      if @seller
        @campaign = @seller.campaign
        
        if !current_user.is_seller?(@campaign)
          redirect_to root_path and return
        end
        
        @contacts = @seller.user_profile.user.contacts
        
        session[:contact_seller_id] = @seller.id
        
        @step_popup = session[:seller_step_popup] || "yes"
      else
        redirect_to root_path and return
      end
    end
    
    def seller_my_contacts
      
      seller = Seller.find_by_id(params[:id])
      @contacts = seller.user_profile.user.contacts
      render :layout => false
      
    end
    
    def seller_email_contacts
      seller = Seller.find_by_id(params[:id])
    
      if seller && seller.user_profile.user_id==current_user.id
        @contacts = seller.user_profile.user.contacts
      else
        @contacts = current_user.contacts
      end
      
      render partial: "email_contacts"
    end
    
    def seller_sendemails
      @seller = Seller.find_by_id(params[:id]) 
      
      if @seller
        @campaign = @seller.campaign
        
        if !current_user.is_seller?(@campaign)
          redirect_to root_path and return
        end
        
        @email_msg = @seller.email_text || ""
    
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
            @email_msg = @email_msg.gsub(/\{\{seller\.fullname\}\}/, @seller.user_profile.fullname)
            @email_msg = @email_msg.gsub(/\{\{seller\.url\}\}/, short_campaign_url(@campaign, seller: @seller.referral_code))
        end
        
        @admin_setting = AdminSetting.first
        @default_email_msg = ""
        @default_email_msg_two = ""
        
        if @admin_setting
            @default_email_msg = @admin_setting.default_email_message || ""
            
            if @default_email_msg != ""
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
                @default_email_msg = @default_email_msg.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
                @default_email_msg = @default_email_msg.gsub(/\{\{seller\.fullname\}\}/, @seller.user_profile.fullname)
                @default_email_msg = @default_email_msg.gsub(/\{\{seller\.url\}\}/, short_campaign_url(@campaign, seller: @seller.referral_code))
                @default_email_msg = @default_email_msg.gsub(/\{\{contact\.greeting\}\}/, "")
            end
            
            @default_email_msg_two = @admin_setting.default_email_message_two || ""
            
            if @default_email_msg != ""
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(@campaign))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.chairperson\}\}/, @campaign.organizer.profile.fullname)
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(@campaign))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.title\}\}/, @campaign.title || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.tagline\}\}/, @campaign.organizer_quote || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{fundraiser\.goal\}\}/, (@campaign.goal.nil? ? "" : "$" + short_price(@campaign.goal.nil? ? 0 : @campaign.goal)))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{organization\.name\}\}/, @campaign.organization.name || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{collection\.name\}\}/, @campaign.collection.try(:name) || "")
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{seller\.fullname\}\}/, @seller.user_profile.fullname)
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{seller\.url\}\}/, short_campaign_url(@campaign, seller: @seller.referral_code))
                @default_email_msg_two = @default_email_msg_two.gsub(/\{\{contact\.greeting\}\}/, "")
            end
        end
        
        @step_popup = session[:seller_step_popup] || "yes"
      else
        redirect_to root_path and return
      end
    end
    
    def ajax_invite_contacts
      
      begin
          AdminMailer.invite_contacts("", params[:email], params[:body]).deliver
          params[:contact_ids].split(",").each do |id|
              emailShareHistory = EmailShareHistory.new
              emailShareHistory.contact_id = id
              emailShareHistory.seller_id = params[:seller_id]
              emailShareHistory.date_sent = DateTime.now
              emailShareHistory.save
          end
      rescue => exception
          logger.info exception.message
      end
  
      render text: 'success'
      
    end
    
    def ajax_import_contacts
      
      begin
        contacts = params[:contacts]
        
        if params[:seller_id].present?
          seller = Seller.find_by_id(params[:seller_id])
        
          if !seller || seller.user_profile.user_id!=current_user.id
            render text: 'failed' and return
          end
        end
        
        contact_ids = []
        
        contacts.each do |c|

            contact = Contact.where(:email_address=>c[1][:email_address], :user_id=>current_user.id).first
            if !contact
              media_id = c[1][:media_id].to_i
              
              # media_id: 1-gmail, 2-yahoo, 3-hotmail, 4-facebook, 5-manual
              if ![1,2,3,4,5].include?(media_id)
                media_id = 5
              end
              
              contact = Contact.new
              contact.first_name = c[1][:first_name]
              contact.last_name = c[1][:last_name]
              contact.email_address = c[1][:email_address]
              contact.media_id = media_id
              contact.user_id = current_user.id
              contact.save
            end
            
            contact_ids << contact.id

        end

        render text: contact_ids.join(",")
      rescue => exception
          logger.info exception.message
          render text: 'failed'
      end
      
    end
    
    def ajax_update_contact
      begin
        contact = Contact.find_by_id(params[:contact_id])
        first_name = params[:first_name]
        last_name = params[:last_name]
        email = params[:email]
        greetings = params[:greetings]
        media_id = params[:media_id].to_i
        
        if contact && contact.user_id!=current_user.id
          render text: "" and return
        end
        
        # media_id: 1-gmail, 2-yahoo, 3-hotmail, 4-facebook, 5-manual
        if ![1,2,3,4,5].include?(media_id)
          media_id = 5
        end
        
        if !contact
          contact = Contact.where(:email_address=>email, :user_id=>current_user.id).first
          
          if contact
            render text: "existed" and return
          else
            contact = Contact.new
          end
        end
        
        contact.first_name = first_name
        contact.last_name = last_name
        contact.email_address = email
        contact.media_id = media_id
        contact.user_id = current_user.id
        contact.greetings = greetings
        contact.save
        
        render text: contact.id.to_s
      rescue => exception
          logger.info exception.message
          render text: ""
      end
    end
    
    def ajax_delete_contact
      begin
        contact = Contact.find_by_id(params[:contact_id])
      
        if !contact || contact.user_id!=current_user.id
          render text: "" and return
        end
        
        contact.destroy

        render text: "done"
      rescue => exception
          logger.info exception.message
          render text: ""
      end
    end
    
    def ajax_email_contacts
      begin
        email_text = params[:email_text]
        is_send_email = params[:is_send_email]
        contact_ids = (params[:contact_ids] || "").split(",")
        seller = nil
        campaign = nil
        
        if params[:seller_id].present?
          seller = Seller.find_by_id(params[:seller_id])
          
          if !seller || seller.user_profile.user_id!=current_user.id
            render text: 'failed' and return
          end
          
          campaign = seller.campaign
          contacts = Contact.where(:id=>contact_ids, :user_id=>current_user.id)
        end
        
        is_campaign = false
        
        if params[:campaign_id].present?
          campaign = Campaign.find_by_id(params[:campaign_id])
          
          if !campaign || campaign.organizer_id!=current_user.id
            render text: 'failed' and return
          end
          
          contacts = Contact.where(:id=>contact_ids, :user_id=>current_user.id)
          
          is_campaign = true
        end
        
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
        # {{contact.greeting}} - Contact greeting
        
        if email_text.present?
            email_text = email_text.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(campaign))
            email_text = email_text.gsub(/\{\{fundraiser\.chairperson\}\}/, campaign.organizer.profile.fullname)
            email_text = email_text.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(campaign))
            email_text = email_text.gsub(/\{\{fundraiser\.title\}\}/, campaign.title || "")
            email_text = email_text.gsub(/\{\{fundraiser\.tagline\}\}/, campaign.organizer_quote || "")
            email_text = email_text.gsub(/\{\{fundraiser\.goal\}\}/, (campaign.goal.nil? ? "" : "$" + short_price(campaign.goal.nil? ? 0 : campaign.goal)))
            email_text = email_text.gsub(/\{\{organization\.name\}\}/, campaign.organization.name || "")
            email_text = email_text.gsub(/\{\{collection\.name\}\}/, campaign.collection.name || "")
            email_text = email_text.gsub(/\{\{seller\.fullname\}\}/, seller ? seller.user_profile.fullname : "")
            email_text = email_text.gsub(/\{\{seller\.url\}\}/, seller ? short_campaign_url(campaign, seller: seller.referral_code) : "")
        end
        
        if seller
          seller.email_text = email_text
          seller.save
        end
        
        if is_campaign
          campaign.email_text = email_text
          campaign.save
        end
        
        if is_send_email == "true"
          # Read default email message
          admin_setting = AdminSetting.first
          default_email_msg = ""
          default_email_msg_two = ""
          
          if seller
            default_email_msg = admin_setting.default_email_message || ""
            default_email_msg_two = admin_setting.default_email_message_two || ""
          end
        
          if is_campaign
            default_email_msg = admin_setting.default_cp_email_message || ""
            default_email_msg_two = admin_setting.default_cp_email_message_two || ""
          end
          
          if default_email_msg != ""
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(campaign))
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.chairperson\}\}/, campaign.organizer.profile.fullname)
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(campaign))
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.title\}\}/, campaign.title || "")
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.tagline\}\}/, campaign.organizer_quote || "")
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.goal\}\}/, (campaign.goal.nil? ? "" : "$" + short_price(campaign.goal.nil? ? 0 : campaign.goal)))
            default_email_msg = default_email_msg.gsub(/\{\{organization\.name\}\}/, campaign.organization.name || "")
            default_email_msg = default_email_msg.gsub(/\{\{collection\.name\}\}/, campaign.collection.name || "")
            default_email_msg = default_email_msg.gsub(/\{\{seller\.fullname\}\}/, seller ? seller.user_profile.fullname : "")
            default_email_msg = default_email_msg.gsub(/\{\{seller\.url\}\}/, seller ? short_campaign_url(campaign, seller: seller.referral_code) : "")
          end
          
          if default_email_msg_two != ""
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(campaign))
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.chairperson\}\}/, campaign.organizer.profile.fullname)
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(campaign))
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.title\}\}/, campaign.title || "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.tagline\}\}/, campaign.organizer_quote || "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.goal\}\}/, (campaign.goal.nil? ? "" : "$" + short_price(campaign.goal.nil? ? 0 : campaign.goal)))
            default_email_msg_two = default_email_msg_two.gsub(/\{\{organization\.name\}\}/, campaign.organization.name || "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{collection\.name\}\}/, campaign.collection.name || "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{seller\.fullname\}\}/, seller ? seller.user_profile.fullname : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{seller\.url\}\}/, seller ? short_campaign_url(campaign, seller: seller.referral_code) : "")
          end
          
          send_text = default_email_msg + email_text + default_email_msg_two
          
          # Send email to all contacts
          contacts.each do |contact|
            begin
                greeting = contact.greetings || ""
                
                if greeting == ""
                    greeting = contact.first_name || ""
                end
                
                email_body = send_text.gsub(/\{\{contact\.greeting\}\}/, greeting)
            
                if is_campaign
                  AdminMailer.invite_contacts(campaign.organizer.email, contact.email_address, email_body, "Please support our fundraiser!").deliver
                else
                  if seller
                    subject = "Please support " + (seller.user_profile.fullname || "our fundraiser") + "!"
                    AdminMailer.invite_contacts(seller.user_profile.user.email, contact.email_address, email_body, subject).deliver
                  end
                end
                
                if seller
                  EmailShareHistory.create :contact_id=>contact.id, :seller_id=>seller.id, :date_sent=>DateTime.now
                end
            rescue => ex
                logger.info exception.message
            end
          end
        end
        
        render text: (is_send_email == "true" ? 'success' : email_text)
      rescue => exception
        logger.info exception.message
        render text: 'failed'
      end
    end
    
    def ajax_preview_contact_email
      begin
        can_parse = true
        email_text = params[:email_text] || ""
        seller = nil
        campaign = nil
        admin_setting = AdminSetting.first
        default_email_msg = ""
        default_email_msg_two = ""
        
        if params[:seller_id].present?
          seller = Seller.find_by_id(params[:seller_id])
          
          if !seller || seller.user_profile.user_id!=current_user.id
            can_parse = false
          else
            campaign = seller.campaign
            
            if admin_setting
                default_email_msg = admin_setting.default_email_message || ""
                default_email_msg_two = admin_setting.default_email_message_two || ""
            end
          end
        end
        
        if params[:campaign_id].present?
          campaign = Campaign.find_by_id(params[:campaign_id])
          
          if !campaign || campaign.organizer_id!=current_user.id
            can_parse = false
          else
            if admin_setting
                default_email_msg = admin_setting.default_cp_email_message || ""
                default_email_msg_two = admin_setting.default_cp_email_message_two || ""
            end
          end
        end
        
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
        # {{contact.greeting}} - Contact greeting
        
        if can_parse
          if default_email_msg != ""
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.signup\.url\}\}/, campaign ? signup_seller_url(campaign) : "")
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.chairperson\}\}/, campaign ? campaign.organizer.profile.fullname : "")
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.url\}\}/, campaign ? short_campaign_url(campaign) : "")
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.title\}\}/, campaign ? (campaign.title || "") : "")
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.tagline\}\}/, campaign ? (campaign.organizer_quote || "") : "")
            default_email_msg = default_email_msg.gsub(/\{\{fundraiser\.goal\}\}/, campaign ? (campaign.goal.nil? ? "" : "$" + short_price(campaign.goal.nil? ? 0 : campaign.goal)) : "")
            default_email_msg = default_email_msg.gsub(/\{\{organization\.name\}\}/, campaign ? (campaign.organization.name || "") : "")
            default_email_msg = default_email_msg.gsub(/\{\{collection\.name\}\}/, campaign ? (campaign.collection.name || "") : "")
            default_email_msg = default_email_msg.gsub(/\{\{seller\.fullname\}\}/, seller ? seller.user_profile.fullname : "")
            default_email_msg = default_email_msg.gsub(/\{\{seller\.url\}\}/, seller ? short_campaign_url(campaign, seller: seller.referral_code) : "")
            default_email_msg = default_email_msg.gsub(/\{\{contact\.greeting\}\}/, "")
          end
        
          if default_email_msg_two != ""
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.signup\.url\}\}/, campaign ? signup_seller_url(campaign) : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.chairperson\}\}/, campaign ? campaign.organizer.profile.fullname : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.url\}\}/, campaign ? short_campaign_url(campaign) : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.title\}\}/, campaign ? (campaign.title || "") : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.tagline\}\}/, campaign ? (campaign.organizer_quote || "") : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{fundraiser\.goal\}\}/, campaign ? (campaign.goal.nil? ? "" : "$" + short_price(campaign.goal.nil? ? 0 : campaign.goal)) : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{organization\.name\}\}/, campaign ? (campaign.organization.name || "") : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{collection\.name\}\}/, campaign ? (campaign.collection.name || "") : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{seller\.fullname\}\}/, seller ? seller.user_profile.fullname : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{seller\.url\}\}/, seller ? short_campaign_url(campaign, seller: seller.referral_code) : "")
            default_email_msg_two = default_email_msg_two.gsub(/\{\{contact\.greeting\}\}/, "")
          end
          
          email_text = email_text.gsub(/\{\{fundraiser\.signup\.url\}\}/, signup_seller_url(campaign))
          email_text = email_text.gsub(/\{\{fundraiser\.chairperson\}\}/, campaign.organizer.profile.fullname)
          email_text = email_text.gsub(/\{\{fundraiser\.url\}\}/, short_campaign_url(campaign))
          email_text = email_text.gsub(/\{\{fundraiser\.title\}\}/, campaign.title || "")
          email_text = email_text.gsub(/\{\{fundraiser\.tagline\}\}/, campaign.organizer_quote || "")
          email_text = email_text.gsub(/\{\{fundraiser\.goal\}\}/, (campaign.goal.nil? ? "" : "$" + short_price(campaign.goal.nil? ? 0 : campaign.goal)))
          email_text = email_text.gsub(/\{\{organization\.name\}\}/, campaign.organization.name || "")
          email_text = email_text.gsub(/\{\{collection\.name\}\}/, campaign.collection.name || "")
          email_text = email_text.gsub(/\{\{seller\.fullname\}\}/, seller ? seller.user_profile.fullname : "")
          email_text = email_text.gsub(/\{\{seller\.url\}\}/, seller ? short_campaign_url(campaign, seller: seller.referral_code) : "")
        else
            email_text = email_text.gsub(/\{\{fundraiser\.signup\.url\}\}/, "")
            email_text = email_text.gsub(/\{\{fundraiser\.chairperson\}\}/, "")
            email_text = email_text.gsub(/\{\{fundraiser\.url\}\}/, "")
            email_text = email_text.gsub(/\{\{fundraiser\.title\}\}/, "")
            email_text = email_text.gsub(/\{\{fundraiser\.tagline\}\}/, "")
            email_text = email_text.gsub(/\{\{fundraiser\.goal\}\}/, "")
            email_text = email_text.gsub(/\{\{organization\.name\}\}/, "")
            email_text = email_text.gsub(/\{\{collection\.name\}\}/, "")
            email_text = email_text.gsub(/\{\{seller\.fullname\}\}/, "")
            email_text = email_text.gsub(/\{\{seller\.url\}\}/, "")
        end
        
        email_text = email_text.gsub(/\{\{contact\.greeting\}\}/, "")
        
        render text: default_email_msg + email_text + default_email_msg_two
      rescue => exception
        logger.info exception.message
        render text: default_email_msg + email_text + default_email_msg_two
      end
    end
    
    def ajax_social_share
      begin
        post_id = params[:post_id]
        media_id = params[:media_id]
        seller = Seller.find_by_id(params[:seller_id])
        
        SocialShareHistory.create :seller_id=>seller.id, :post_id=>post_id, :media_id=>media_id, :date_shared=>DateTime.now
        
        render text: 'success'
      rescue => exception
        logger.info exception.message
        render text: 'failed'
      end
    end
    
    def ajax_seller_step_popup
        begin
          popup = params[:popup]
          
          if popup == "disable"
              session[:seller_step_popup] = "no"
          end
                  
          render text: session[:seller_step_popup] || "yes"
        rescue => exception
          logger.info exception.message
          render text: session[:seller_step_popup] || "yes"
        end
    end
    
    def seller_delete_contacts
      @contact = Contact.find_by_id(params[:id])
      
      if !@contact
        redirect_to root_path, flash: { danger: "Contact does not exist" } and return
      end
      
      id = @contact.user.user_profiles.first.sellers.first.id
      
      @contact.destroy
      redirect_to seller_my_contacts_url(id), flash: { success: "Contact has been deleted" }
    end
    
    def signup_seller_share
      @seller = Seller.find_by_id(params[:seller_id])
      
      if @seller
        @campaign = @seller.campaign
        
        if !current_user.is_seller?(@campaign)
          redirect_to root_path and return
        end
      else
        redirect_to root_path and return
      end     
    end
    
    def signup_seller_finish
      @seller = Seller.find_by_id(params[:seller_id])
      
      if @seller
        @campaign = @seller.campaign
        
        if !current_user.is_seller?(@campaign)
          redirect_to root_path and return
        end
        
        redirect_to seller_dashboard_referral_code_url(@seller.referral_code), flash: { success: "You have succesfully joined this fundraiser, share your link below!" } and return
      else
        redirect_to root_path and return
      end
    end
        
    def settings_profile
        @user_profile = current_user.profile
    end

    def update_profile
        @user_profile = current_user.profile
        @user_profile.assign_attributes user_profile_params
        
        unless @user_profile.save
            message = ''
            @user_profile.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            redirect_to(settings_profile_url, flash: { danger: message[0...-2] }) and return
        end
        
        if params[:user_picture].present?
            preloaded = Cloudinary::PreloadedFile.new(params[:user_picture])
            if preloaded.valid?
                @user_profile.update_attribute(:picture, preloaded.identifier)
            end
        else
            if params[:use_photo].present?
              # Use default photo, so upload the url passed in to cloud
              # Note: it does not work on localhost since the url is not public
              
              image_hash = Cloudinary::Uploader.upload(params[:use_photo], :tags => "custom-user-photo")

              @user_profile.update_attribute(:picture, image_hash["public_id"])
            end
        end

        redirect_to(settings_profile_url, flash: { success: "个人资料保存成功" }) and return
    end

    def settings_account
    end

    def update_account
        @user = current_user
        
        redirect_to(settings_account_url, flash: { warning: "当前密码不正确" }) and return unless @user.valid_password?(params[:user][:password])
        redirect_to(settings_account_url, flash: { warning: "新密码不能为空" }) and return unless params[:new_password].present?

        @user.password = params[:new_password]
        @user.password_confirmation = params[:new_password]
        
        unless @user.save
            message = ''
            @user.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            redirect_to(settings_account_url, flash: { danger: message[0...-2] }) and return
        end
        
        sign_in(@user, :bypass=>true)

        redirect_to(settings_account_url, flash: { success: "重设密码成功" }) and return
    end
    
    def omniauth_callback
      @auth = request.env["omniauth.auth"].to_json
      @provider = request.env["omniauth.auth"]["provider"]
    end
    
    def omniauth_failure
      
    end
    
    private
    # Using a private method to encapsulate the permissible parameters is
    # just a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def user_params
        params.require(:user).permit :email, :password, :parent_account
    end

    def user_profile_params
        params.require(:user_profile).permit :first_name, :last_name, :display_name, :title
    end

    def account_params
        params.require(:user).permit :email
    end
end
