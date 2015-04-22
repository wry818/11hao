class Admin::CategoriesController < Admin::ApplicationController
    before_filter :load_collection

    def new
        @category = Category.new
    end

    def create
        @category = Category.new(category_params)

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@category.valid?
            message = ''
            @category.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "new" and return
        end

        @category.save
        @collection.categories << @category

        if params[:category_image].present? && params[:remove_item_image]=="no"
            preloaded = Cloudinary::PreloadedFile.new(params[:category_image])
            if preloaded.valid?
                @category.update_attribute(:picture, preloaded.identifier)
            end
        end

        redirect_to admin_collection_url(@collection), flash: { success: "Category succesfully created" }
    end

    def edit
        @category = Category.friendly.find(params[:id])
    end

    def update
        @category = Category.friendly.find(params[:id])
        @category.assign_attributes(category_params)

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@category.valid?
            message = ''
            @category.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "new" and return
        end

        @category.save
        
        if params[:remove_item_image]=="yes"
           @category.update_attribute(:picture, "")
        else
          if params[:category_image].present?
              preloaded = Cloudinary::PreloadedFile.new(params[:category_image])
              if preloaded.valid?
                  @category.update_attribute(:picture, preloaded.identifier)
              end
          end
        end

        redirect_to admin_collection_url(@collection), flash: { success: "Category succesfully updated" }
    end

    def destroy
      @category = Category.friendly.find(params[:id])
      
      if !@category
        redirect_to admin_collection_url(@collection), flash: { danger: "Category does not exist" } and return
      end
      
      if @category.products.count>0
        redirect_to admin_collection_url(@collection), flash: { 
          danger: "The category cannot be deleted. It is currently used by one or more products." } and return
      end
      
      if @category
        @category.delete
      end
      
      redirect_to admin_collection_url(@collection), flash: { success: "Category succesfully deleted" }
    end

    private

    def load_collection
        @collection = Collection.friendly.find(params[:collection_id])
        redirect_to admin_root, flash: { danger: "Collection wasn't found" } unless @collection
    end

    def category_params
        params.require(:category).permit :name, :description
    end
end
