class Admin::MallController < Admin::ApplicationController
  def settings
    @root_categories = ProductCategory.showroot.order(:sort_mark)
    @all_products = Product.isnot_destroy.order(:id=>:desc)
    @top_categories = MallTopCategory.all
    @slider_images = MallSliderImage.all
    @hot_products = MallHotProduct.all
  end
  
  def save_settings
    MallTopCategory.all.each do |c|
      c.delete
    end
    
    MallSliderImage.all.each do |i|
      i.delete
    end
    
    MallHotProduct.all.each do |p|
      p.delete
    end
    
    if params[:top_pc].present? && params[:top_pc_order].present?
      params[:top_pc].each_with_index { |pc, idx| 
        MallTopCategory.create product_category_id: pc, sort_order: params[:top_pc_order][idx].to_i
      }
    end
    
    if params[:hot_prod].present? && params[:hot_prod_order].present?
      params[:hot_prod].each_with_index { |hp, idx| 
        MallHotProduct.create product_id: hp, sort_order: params[:hot_prod_order][idx].to_i
      }
    end
    
    redirect_to admin_mall_settings_path and return
  end
end
