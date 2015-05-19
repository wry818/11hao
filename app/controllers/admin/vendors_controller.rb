class Admin::VendorsController < Admin::ApplicationController
  before_filter :load_vendor, only: [:edit, :update, :destroy]
  
  def index
    @vendors = Vendor.active.order(:id)
  end
  
  def new
     @vendor = Vendor.new
  end
  
  def create
    @vendor = Vendor.new(vendor_params)
    
    if !@vendor.valid?
        message = ''
        @vendor.errors.each do |key, error|
            message = message + key.to_s.humanize + ' ' + error.to_s + ', '
        end
        flash.now[:danger] = message[0...-2]
        render action: "new" and return
    end
    
    @vendor.save
    
    redirect_to admin_vendors_path, flash: { success: "Vendor created" }
  end
  
  def edit
    
  end
  
  def update
    @vendor.assign_attributes(vendor_params)

    if !@vendor.valid?
        message = ''
        @vendor.errors.each do |key, error|
            message = message + key.to_s.humanize + ' ' + error.to_s + ', '
        end
        flash.now[:danger] = message[0...-2]
        render action: "new" and return
    end

    @vendor.save

    redirect_to admin_vendors_path, flash: { success: "Vendor updated" }
  end
  
  def destroy
    @vendor.active = false
    @vendor.deleted = true
    @vendor.save
    
    redirect_to admin_vendors_path, flash: { success: "Vendor deleted" }
  end
  
  private
  
  def vendor_params
      params.require(:vendor).permit :name, :email
  end
  
  def load_vendor
    begin
      @vendor = Vendor.find(params[:id])
    rescue
      redirect_to admin_root_path and return
    end
  end
end
