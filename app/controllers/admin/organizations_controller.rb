class Admin::OrganizationsController < Admin::ApplicationController
  before_filter :load_organization, only: [:edit, :update, :destroy]
  before_filter :load_countries_states, only: [:new, :create, :edit, :update]
  before_filter :load_campaign, only: [:edit, :update]
  
  def index
    @organizations = Organization.active.order(:id)
  end

  def ajax_pager_data
    @organizations=Organization.active.order(:updated_at => :desc).page(params[:page]).per(Kaminari.config.default_per_page);

    render partial: "table_show"
  end

  def new
     @organization = Organization.new
  end
  
  def create
    @organization = Organization.new
    
    @organization.assign_attributes(organization_params)
    @organization.entertainment_customer_id = Time.now.to_i.to_s
    
    if !@organization.valid?
        message = ''
        @organization.errors.each do |key, error|
            message = message + key.to_s.humanize + ' ' + error.to_s + ', '
        end
        flash.now[:danger] = message[0...-2]
        render action: "new" and return
    end
    
    @organization.save
    
    redirect_to admin_organizations_path, flash: { success: "组织已创建" }
  end
  
  def edit
    
  end
  
  def update
    @organization.assign_attributes(organization_params)
    
    if !@organization.valid?
        message = ''
        @organization.errors.each do |key, error|
            message = message + key.to_s.humanize + ' ' + error.to_s + ', '
        end
        flash.now[:danger] = message[0...-2]
        render action: "edit" and return
    end
    
    @organization.save
    
    redirect_to admin_organizations_path, flash: { success: "组织已更新" }
  end
  
  def destroy
    @organization.deleted=true
    @organization.save

    @organization.campaigns.each do |cap|
      cap.update(is_destroy:true)
    end

    campaign = Campaign.where(:organization_id=>@organization.id, :campaign_type=>2).first
    
    if campaign
      campaign.active = false
      campaign.save
    end
    
    redirect_to admin_organizations_path, flash: { success: "组织已删除" }
  end
  
  private
  
  def organization_params
      params.require(:organization).permit :name, :address_line_one, :address_line_two, :address_city,
      :state_province_id, :address_postal_code, :country_id
  end
  
  def load_organization
    begin
      @organization = Organization.friendly.find(params[:id])
    rescue
      redirect_to admin_root_path and return
    end
  end
  
  def load_countries_states
    @countries = Country.order(:id)
    @state_provinces = StateProvince.order(:id)
  end
  
  def load_campaign
    @campaign = Campaign.where(organization_id: @organization.id, campaign_type: 2).first
  end
end
