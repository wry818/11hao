class Admin::UsersController < Admin::ApplicationController
    
    def index
      @users = User.isnot_destroy.order(:id)
    end
      
    def new
        @user = User.new
        @account_types = AccountType.where("id=4 or id=5").order(:id)
        @user_organizations = @user.organizations.order(:id).select(:id, :name)
        @not_user_organizations = Organization.active.all(:select => "id, name")
    end

    def create
        @user = User.new user_params
        @user.password_confirmation = @user.password
        @account_types = AccountType.where("id=4 or id=5").order(:id)
        @user_organizations = @user.organizations.order(:id).select(:id, :name)
        @not_user_organizations = Organization.active.all(:select => "id, name")
        
        unless @user.save
            message = ''
            @user.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "new" and return
        end

        userprofile = params[:user_profile]
        profile = UserProfile.create user: @user, first_name: userprofile['first_name'], last_name: userprofile['last_name'], phone_number: userprofile['phone_number'], display_name: userprofile['display_name'], title: userprofile['title'], child_profile: false

        if params[:user_profile_picture].present?
            preloaded = Cloudinary::PreloadedFile.new(params[:user_profile_picture])
            if preloaded.valid?
                @user_profile.update_attribute(:picture, preloaded.identifier)
            end
        else
            if params[:use_photo].present?
              # Use default photo, so upload the url passed in to cloud
              # Note: it does not work on localhost since the url is not public
              
              image_hash = Cloudinary::Uploader.upload(params[:use_photo], :tags => "custom-user-photo")

              @user_profile. (:picture, image_hash["public_id"])
            end
        end

        if @user.account_type == 4 && params[:user_organization_ids].present?
            ids = params[:user_organization_ids].split(",").map(&:to_i)
            user_organizations = Organization.all(:conditions => ["id in (?)", ids])
            @user.organizations << user_organizations
        end
        
        redirect_to admin_users_url, flash: { success: "用户已创建" }

    end

    def edit
      @user = User.find(params[:id])
      @account_types = AccountType.where("id=4 or id=5").order(:id)
      @user_organizations = @user.organizations.order(:id).select(:id, :name)
      
      ids = @user_organizations.collect(&:id)
      if ids.count > 0
        @not_user_organizations = Organization.active.all(:select => "id, name", :conditions => ["id not in (?)", ids])
      else
        @not_user_organizations = Organization.active.all(:select => "id, name")
      end
      
    end

    def update
        @user = User.find(params[:id])
        @account_types = AccountType.where("id=4 or id=5").order(:id)
        @user_organizations = @user.organizations.order(:id).select(:id, :name)
      
        ids = @user_organizations.collect(&:id)
        if ids.count > 0
          @not_user_organizations = Organization.active.all(:select => "id, name", :conditions => ["id not in (?)", ids])
        else
          @not_user_organizations = Organization.active.all(:select => "id, name")
        end
        
        if params[:user][:password].present?
          @user.assign_attributes(user_params)
          @user.password_confirmation = @user.password
        else
          @user.assign_attributes(user_params_no_pwd)
        end

        unless @user.save
            message = ''
            @user.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "edit" and return
        end

        @user.profile.update_attributes(user_profile_params)
        
        if params[:user_profile_picture].present?
            preloaded = Cloudinary::PreloadedFile.new(params[:user_profile_picture])
            if preloaded.valid?
                @user.profile.update_attribute(:picture, preloaded.identifier)
            end
        else
            if params[:use_photo].present?
              # Use default photo, so upload the url passed in to cloud
              # Note: it does not work on localhost since the url is not public
              
              image_hash = Cloudinary::Uploader.upload(params[:use_photo], :tags => "custom-user-photo")

              @user.profile.update_attribute(:picture, image_hash["public_id"])
            end
        end

        @user.organizations.clear

        if @user.account_type == 4 && params[:user_organization_ids].present?
            ids = params[:user_organization_ids].split(",").map(&:to_i)
            user_organizations = Organization.all(:conditions => ["id in (?)", ids])
            @user.organizations << user_organizations
        end
        
        redirect_to admin_users_url, flash: { success: "用户已更新" }

    end

    def destroy
        @user=User.find(params[:id])
        @user.update(is_destroy:true)
        redirect_to admin_users_url, flash: { success: "用户已删除" }
    end
    private

    def user_params
        params.require(:user).permit :email, :password, :admin_flag, :account_type
    end
    
    def user_params_no_pwd
        params.require(:user).permit :email, :admin_flag, :account_type
    end

    def user_profile_params
        params.require(:user_profile).permit :first_name, :last_name, :phone_number, :display_name, :title
    end

end
