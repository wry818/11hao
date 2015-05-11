class Admin::ProductsController < Admin::ApplicationController

    def index
        @products = Product.order(:id)
    end

    def new
        @product = Product.new
    end

    def create
        @product = Product.new(product_params)
        
        if params[:product_collection_id].present? && @product.is_featured
            collection = Collection.find_by_id(params[:product_collection_id])
            
            if collection.products.where(:is_featured=>true).count>=6              
              flash.now[:danger] = "You can only have up to 6 featured products in " + collection.name
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

        redirect_to admin_products_url, flash: { success: "Product created" }

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
              flash.now[:danger] = "You can only have up to 6 featured products in " + collection.name
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
        else
          if params[:product_image].present?
              preloaded = Cloudinary::PreloadedFile.new(params[:product_image])
              if preloaded.valid?
                  @product.update_attribute(:picture, preloaded.identifier)
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

        redirect_to admin_products_url, flash: { success: "Product updated" }
    end

    def destroy
        @product = Product.friendly.find(params[:id])
        
        if !@product
          redirect_to admin_products_url, flash: { danger: "Product does not exist" } and return
        end
        
        if @product.items.count>0
          redirect_to admin_products_url, flash: { 
            danger: "The product cannot be deleted. It is currently used by one or more orders." } and return
        end
        
        @product.destroy
        redirect_to admin_products_url, flash: { success: "Product deleted" }
    end
    
    def prod_collections
      @product = Product.find_by_id(params[:id])
      @collections = Collection.where("id>0").order(:id)
      @categories = Category.order(:id)
      
      render partial: "collections"
    end
    
    def edit_option_group
      begin
        @product = Product.friendly.find(params[:product_id])
      rescue ActiveRecord::RecordNotFound
      end
      
      if !@product
        redirect_to admin_products_url, flash: { danger: "Product does not exist" } and return
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
        redirect_to admin_products_url, flash: { danger: "Product does not exist" } and return
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
        redirect_to admin_products_url, flash: { danger: "Product does not exist" } and return
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
        params.require(:product).permit :name, :description, :picture, :base_price, :default_donation_amount, :show_quantity, :is_featured, :fulfillment_method, :sku, :vendor, :original_price
    end
    
    def option_group_params
      params.require(:option_group).permit :name, :instructions, :required
    end

end
