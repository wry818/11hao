class Admin::WeishopController < ApplicationController
  layout 'admin/layouts/application'
  
  def settings
    shop_url = ShopUrl.first
    @url = shop_url.url
  end
  
  def save_settings
    
    shop_url = ShopUrl.first
    shop_url.url = params["weishop_url"]
    shop_url.save
    
    redirect_to admin_weishop_settings_path and return
    
  end
  
end