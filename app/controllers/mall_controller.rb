class MallController < ApplicationController
  layout "mall"
  
  before_filter :load_mall, only: [:home, :search, :orders, :order_detail]
  before_filter :manage_session_order, only: [:home, :search, :orders, :order_detail]
  
  def home
    @products = Product.isnot_destroy.first(6)
  end
  
  def search
    @products = Product.isnot_destroy
    
    if params[:mall_search_text].present?
      @products = @products.where("name ilike :search", search: '%' + params[:mall_search_text] + '%')
    end
    
    if params[:category_id].present?
      @products = @products.where(:product_category_id => params[:category_id].to_i)
    end
    
    if params[:subcategory_id].present?
      @products = @products.where(:pro_cat_subclass_id => params[:subcategory_id].to_i)
    end
    
    @products = @products.order(:id)
  end
  
  def orders
    @orders = Order.where(open_id: session[:openid]).completed.order(:id=>:desc)
  end
  
  def order_detail
    @the_order = Order.where(:open_id => session[:openid], :id => params[:id].to_i).first
    
    if !@the_order
      redirect_to mall_home_path and return
    end
  end
  
  private
  
  def load_mall
    @campaign = Campaign.find_by_id(0)
    @root_categories = ProductCategory.showroot.order(:sort_mark)
  end
  
  def manage_session_order
    @order = Order.find_by_id(session[:order_id])
    
    unless @order && @order.campaign_id == @campaign.id && @order.status == 0
      @order = Order.new
    end
  end
end