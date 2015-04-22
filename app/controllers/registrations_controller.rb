class RegistrationsController < Devise::RegistrationsController
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
          render action: "new" and return
      end

      sign_in(@user)

      UserProfile.create user: @user, first_name: params[:first_name], last_name: params[:last_name], child_profile: false

      respond_with resource, location: after_sign_up_path_for(resource)
  end
  
  def signup_social_user
    if !params[:auth_uid].present? || !params[:auth_provider].present?
      if session[:landing]
        redirect_to session[:landing] 
        session[:landing] = nil and return
      else
        redirect_to root_url and return
      end
    end
      
    oldUser = User.find_by uid: params[:auth_uid], provider: params[:auth_provider]
    
    if oldUser
      newUser = oldUser
      
      sign_in(oldUser)
    else
      # Create a new user
      newUser = User.new
      newUser.email = URI.unescape(params[:email])
      newUser.password = DateTime.now.to_s  # fake password
      newUser.password_confirmation = newUser.password
      newUser.uid = params[:auth_uid]
      newUser.provider = params[:auth_provider]
  
      unless newUser.save
        message = ''
        newUser.errors.each do |key, error|
            message = message + key.to_s.humanize + ' ' + error.to_s + ', '
        end
        flash.now[:danger] = message[0...-2]
        
        if session[:landing]
            redirect_to session[:landing], :flash => { :danger => message[0...-2] }
            session[:landing] = nil and return
        else
          redirect_to root_url, :flash => { :danger => message[0...-2] } and return
        end
      end
      
      pic_public_id = ""
      
      if params[:auth_uimage].present?
        begin
          # Save user's social image
          hash=Cloudinary::Uploader.upload(params[:auth_uimage], :tags => "social-user-image")
        rescue
        ensure
        end

        if hash
          pic_public_id = hash["public_id"]
        end
      end
      
      UserProfile.create user: newUser, first_name: URI.unescape(params[:first_name]), last_name: URI.unescape(params[:last_name]), picture: pic_public_id, child_profile: false
      
      sign_in(newUser)
    end
    
    redirect_to after_sign_in_path_for(newUser) and return
  end
  
  private
  # Using a private method to encapsulate the permissible parameters is
  # just a good pattern since you'll be able to reuse the same permit
  # list between create and update. Also, you can specialize this method
  # with per-user checking of permissible attributes.
  def user_params
      params.require(:user).permit :email, :password, :parent_account
  end

end

