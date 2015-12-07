class Admin::ProductsController < Admin::ApplicationController

    def index
      # @products = Product.isnot_destroy.order(:id).all
      # render @products.to_yaml and  return
      @products = Product.isnot_destroy.order(:id)
    end

    def new
        @product = Product.new
    end

    def create
        @product = Product.new(product_params)
        
        if params[:product_collection_id].present? && @product.is_featured
            collection = Collection.find_by_id(params[:product_collection_id])
            
            if collection.products.where(:is_featured=>true).count>=6              
              flash.now[:danger] = "最多只能添加六个义卖商品"
              render action: "new" and return
            end
        end

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@product.valid?
            message = ''
            @product.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            
            flash.now[:danger] = message[0...-2]
            render action: "new" and return
        end

        @product.save

        if params[:product_image].present? && params[:remove_item_image]=="no"
            preloaded = Cloudinary::PreloadedFile.new(params[:product_image])
            if preloaded.valid?
                @product.update_attribute(:picture, preloaded.identifier)
                
                cover_photo = @product.cover_photo
                
                if !cover_photo
                  cover_photo = ProductImage.new product_id: @product.id, public_id: preloaded.identifier, is_cover: true
                else
                  cover_photo.public_id = preloaded.identifier
                  cover_photo.save
                end
            end
        end
        
        if params[:product_collection_id].present?
            collections = Collection.where(:id=>params[:product_collection_id].split(","))
            @product.collections << collections
        end

        if params[:product_category_id].present?
            categories = Category.where(:id=>params[:product_category_id].split(","))
            @product.categories << categories
        end
        
        if params[:more_photo_public_id].present?
          params[:more_photo_public_id].each do |public_id|
            ProductImage.create product_id: @product.id, public_id: public_id, is_cover: false
          end
        end

        redirect_to admin_products_url, flash: { success: "商品已创建" }
    end

    def edit
        @product = Product.friendly.find(params[:id])
    end

    def update
        @product = Product.friendly.find(params[:id])
        @product.assign_attributes(product_params)
        
        if params[:product_collection_id].present? && @product.is_featured
            collection = Collection.find_by_id(params[:product_collection_id])
            
            if collection.products.where("is_featured=true and id!=?", @product.id).count>=6              
              flash.now[:danger] = "最多只能添加六个义卖商品"
              render action: "new" and return
            end
        end

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@product.valid?
            message = ''
            @product.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            
            flash.now[:danger] = message[0...-2]
            render action: "new" and return
        end

        @product.save
        
        if params[:remove_item_image]=="yes"
           @product.update_attribute(:picture, "")
           
           cover_photo = @product.cover_photo
           
           if cover_photo
             cover_photo.destroy
           end
        else
          if params[:product_image].present?
              preloaded = Cloudinary::PreloadedFile.new(params[:product_image])
              if preloaded.valid?
                  @product.update_attribute(:picture, preloaded.identifier)
                  
                  cover_photo = @product.cover_photo
                
                  if !cover_photo
                    cover_photo = ProductImage.create product_id: @product.id, public_id: preloaded.identifier, is_cover: true
                  else
                    cover_photo.public_id = preloaded.identifier
                    cover_photo.save
                  end
              end
          end
        end

        @product.collections.clear

        if params[:product_collection_id].present?
            collections = Collection.where(:id=>params[:product_collection_id].split(","))
            @product.collections << collections
        end
        
        @product.categories.clear

        if params[:product_category_id].present?
            categories = Category.where(:id=>params[:product_category_id].split(","))
            @product.categories << categories
        end
        
        if params[:more_photo_public_id].present?
          more_photo = @product.more_photo.all
          
          params[:more_photo_public_id].each do |public_id|
            photo = more_photo.select{|p| p.public_id==public_id}.first
            
            if !photo
              ProductImage.create product_id: @product.id, public_id: public_id, is_cover: false
            end
          end
          
          more_photo.each do |photo|
            if !params[:more_photo_public_id].include?(photo.public_id)
              photo.destroy
            end
          end
        else
          @product.more_photo.each do |photo|
            photo.destroy
          end
        end

        redirect_to admin_products_url, flash: { success: "商品已更新" }
    end

    def destroy
        @product = Product.friendly.find(params[:id])
        
        if !@product
          redirect_to admin_products_url, flash: { danger: "该商品不存在" } and return
        end
        
        # if @product.items.count>0
        #   redirect_to admin_products_url, flash: {
        #     danger: "商品正在使用，无法删除" } and return
        # end
        
        @product.update(is_destroy:true)
        redirect_to admin_products_url, flash: { success: "商品已删除" }
    end
    
    def prod_collections
      @product = Product.find_by_id(params[:id])
      @collections = Collection.isnot_destroy.where("id>0").order(:id)
      @categories = Category.order(:id)
      
      render partial: "collections"
    end
    
    def edit_option_group
      begin
        @product = Product.friendly.find(params[:product_id])
      rescue ActiveRecord::RecordNotFound
      end
      
      if !@product
        redirect_to admin_products_url, flash: { danger: "该商品未找到" } and return
      end
      
      @option_group = @product.option_groups.active.first
      
      if !@option_group
        @option_group = OptionGroup.new
        @option_group.product_id = @product.id
      end
    end
    
    def save_option_group
      begin
        @product = Product.friendly.find(params[:product_id])
      rescue ActiveRecord::RecordNotFound
      end
      
      if !@product
        redirect_to admin_products_url, flash: { danger: "该商品不存在" } and return
      end
      
      @option_group = @product.option_groups.active.first
      
      if !@option_group
        @option_group = OptionGroup.new
        @option_group.product_id = @product.id
      end
      
      @option_group.assign_attributes(option_group_params)
      @option_group.save
      
      properties = @option_group.option_group_properties.active.all
      
      if params[:properties].present?
        # Create or update properties
        params[:properties].each do |prop|
          idx = properties.index{|p| p.id.to_s == prop[:id]}
          
          if idx
            property = properties[idx]
          else
            property = OptionGroupProperty.new
            property.option_group_id = @option_group.id
          end
          
          property.value = prop[:value]
          property.price = prop[:price].to_f
          property.donation_amount = prop[:donation].to_f
          property.sort_order = prop[:order].to_i
          property.sku = prop[:sku]
          property.save
        end
        
        # Destroy properties that are deleted
        properties.each do |prop|
          idx = params[:properties].index{|p| p[:id] == prop.id.to_s}
          
          if !idx
            prop.deleted = true
            prop.save
          end
        end
      else
        properties.each do |prop|
          prop.deleted = true
          prop.save
        end
      end
      
      redirect_to edit_admin_product_path(@product)
    end
    
    def delete_option_group
      begin
        @product = Product.friendly.find(params[:product_id])
      rescue ActiveRecord::RecordNotFound
      end
      
      if !@product
        redirect_to admin_products_url, flash: { danger: "该商品不存在" } and return
      end
      
      @option_group = @product.option_groups.active.first
      
      if @option_group
        @option_group.deleted = true
        @option_group.save
      end
      
      redirect_to edit_admin_product_path(@product)
    end
    
    def save_option_group_property
      begin
        product = Product.friendly.find(params[:product_id])
      rescue ActiveRecord::RecordNotFound
      end
      
      if !product
        render text: "fail" and return
      end
      
      option_group = product.option_groups.active.first
      
      if !option_group
        render text: "fail" and return
      end
      
      property = OptionGroupProperty.find_by_id(params[:id])
      
      if property && property.option_group_id != option_group.id
         render text: "fail" and return
      end
      
      if !property
        property = OptionGroupProperty.new
        property.option_group_id = option_group.id
      end
      
      property.value = params[:value]
      property.price = params[:price].to_f
      property.sort_order = params[:sort_order].to_i
      property.save
      
      render text: "ok"
    end
    
    def delete_option_group_property
      begin
        product = Product.friendly.find(params[:product_id])
      rescue ActiveRecord::RecordNotFound
      end
      
      if !product
        render text: "fail" and return
      end
      
      property = OptionGroupProperty.find_by_id(params[:id])
      
      if !property || !property.option_group
        render text: "fail" and return
      end
      
      option_group = property.option_group
      
      if !option_group.product || option_group.product.id != product.id
        render text: "fail" and return
      end
      
      property.destroy
      
      render text: "ok"
    end

    private
    # Using a private method to encapsulate the permissible parameters is
    # just a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def product_params
        params.require(:product).permit :name, :description, :picture, :base_price, :default_donation_amount, :show_quantity, :is_featured, :fulfillment_method, :sku, :vendor_id, :original_price
    end
    
    def option_group_params
      params.require(:option_group).permit :name, :instructions, :required
    end

end
