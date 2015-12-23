class MallController < ApplicationController
  layout "mall"
  
  before_filter :load_mall, only: [:home, :search, :search_page, :orders, :order_detail]
  before_filter :manage_session_order, only: [:home, :search, :search_page, :orders, :order_detail]
  
  def home
    @products = []
    
    MallHotProduct.order(:sort_order).each do |hp|
      if @products.count >= 6
        break
      end
      
      @products << hp.product if !hp.product.is_destroy
    end
    
    @top_categories = []
    
    MallTopCategory.order(:sort_order).each do |tc|
      if @top_categories.count >= 4
        break
      end
      
      @top_categories << tc.product_category if tc.product_category.active && !tc.product_category.is_destroy
    end
    
    @slider_images = MallSliderImage.order(:sort_order)
  end
  
  def search
    do_search
  end
  
  def search_page
    do_search
    
    render partial: "mall/pager/search" and return
  end
  
  def orders
    do_orders
  end
  
  def orders_page
    do_orders
    
    render partial: "mall/pager/orders" and return
  end
  
  def order_detail
    @the_order = Order.where(:open_id => session[:openid] || "", :id => params[:id].to_i).first
    @items_express=Hash.new
    @the_order.items.each do |item|
      @items_express[item.courier_number]=item
    end
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
  
  def do_orders
    @page = params[:page].to_i
    @page = 1 if @page == 0
    @show_pager = false
    @orders = Order.where(open_id: session[:openid] || "").completed.order(:id=>:desc).page(@page).per(5)
    
    if @orders.total_pages > 0 && @orders.total_pages > @page
      @show_pager = true
      
      query = "?" + {:page => @page + 1}.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")
      
      @page_url = mall_orders_page_path + query
    end
  end
  
  def do_search
    @products = Product.isnot_destroy
    
    if params[:mall_search_text].present?
      tag_prod_ids = Tag.isnot_destroy.is_active.joins(:products).where(
        "tags.name ilike :search", search: '%' + params[:mall_search_text] + '%').select(
        "products.id as prod_id").collect(&:prod_id).uniq
      
      if tag_prod_ids.count > 0
        @products = @products.where("name ilike :search or id in (:tag_prod_ids)", 
          search: '%' + params[:mall_search_text] + '%', tag_prod_ids: tag_prod_ids)
      else
        @products = @products.where("name ilike :search", search: '%' + params[:mall_search_text] + '%')
      end
    end
    
    if params[:category_id].present?
      @products = @products.where(:product_category_id => params[:category_id].to_i)
    end
    
    if params[:subcategory_id].present?
      @products = @products.where(:pro_cat_subclass_id => params[:subcategory_id].to_i)
    end
    
    @page = params[:page].to_i
    @page = 1 if @page == 0
    @show_pager = false
    @products = @products.order(:id => :desc).page(@page).per(5)
    
    if @products.total_pages > 0 && @products.total_pages > @page
      @show_pager = true
      
      query = "?" + {:page => @page + 1,
        :mall_search_text => params[:mall_search_text] || "",
        :category_id => params[:category_id] || "",
        :subcategory_id => params[:subcategory_id] || ""}.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")
      
      @page_url = mall_search_page_path + query
    end
  end
end