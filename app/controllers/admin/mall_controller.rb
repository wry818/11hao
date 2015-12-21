class Admin::MallController < Admin::ApplicationController
  def settings
    @root_categories = ProductCategory.showroot.order(:sort_mark)
    @all_products = Product.isnot_destroy.order(:id=>:desc)
    @top_categories = MallTopCategory.all
    @slider_images = MallSliderImage.order(:sort_order).all
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
    
    if params[:top_pc].present?
      params[:top_pc].each_with_index { |pc, idx| 
        MallTopCategory.create product_category_id: pc, sort_order: params["top_pc_order_" + pc].to_i
      }
    end
    
    if params[:hot_prod].present?
      params[:hot_prod].each_with_index { |hp, idx| 
        MallHotProduct.create product_id: hp, sort_order: (params["hot_prod_order_" + hp] || "999").to_i
      }
    end
    
    if params[:slider_images].present?
      params[:slider_images].each do |si|
        begin
          img_hash = JSON.parse(si)
          
          MallSliderImage.create public_id: img_hash["public_id"], image_url: img_hash["secure_url"],
            image_width: img_hash["image_width"], image_height: img_hash["image_height"], 
            sort_order: img_hash["sort_order"].to_i,
            crop_x: img_hash["crop_x"], crop_y: img_hash["crop_y"], crop_width: img_hash["crop_width"],
            crop_height: img_hash["crop_height"], is_cropped: true, target_url: img_hash["target_url"]
        rescue
        end
      end
    end
    
    redirect_to admin_mall_settings_path and return
  end
end
