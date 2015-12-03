class Admin::CollectionsController < Admin::ApplicationController

    def index
        @collections = Collection.isnot_destroy.order(:id)
    end

    def show
        @collection = Collection.isnot_destroy.friendly.find(params[:id])
    end

    def new
        @collection = Collection.new
    end

    def create
        @collection = Collection.new(collection_params)

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@collection.valid?
            message = ''
            @collection.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "new" and return
        end

        @collection.save

        if params[:collection_image].present? && params[:remove_item_image]=="no"
            preloaded = Cloudinary::PreloadedFile.new(params[:collection_image])
            if preloaded.valid?
                @collection.update_attribute(:picture, preloaded.identifier)
            end
        end

        redirect_to admin_collections_url, flash: { success: "组合已创建" }

    end

    def edit
        @collection = Collection.isnot_destroy.friendly.find(params[:id])
    end

    def update
        @collection = Collection.isnot_destroy.friendly.find(params[:id])
        @collection.assign_attributes(collection_params)

        # Check if the new settings pass validations...if not, re-render form and display errors in flash msg
        if !@collection.valid?
            message = ''
            @collection.errors.each do |key, error|
                message = message + key.to_s.humanize + ' ' + error.to_s + ', '
            end
            flash.now[:danger] = message[0...-2]
            render action: "new" and return
        end

        @collection.save
        
        if params[:remove_item_image]=="yes"
           @collection.update_attribute(:picture, "")
        else
          if params[:collection_image].present?
              preloaded = Cloudinary::PreloadedFile.new(params[:collection_image])
              if preloaded.valid?
                  @collection.update_attribute(:picture, preloaded.identifier)
              end
          end
        end

        redirect_to admin_collections_url, flash: { success: "组合已更新" }
    end

    def destroy
        @collection = Collection.friendly.find(params[:id])
        
        if !@collection
          redirect_to admin_collections_url, flash: { danger: "该组合未找到" } and return
        end
        
        if @collection.campaigns.count>0
          redirect_to admin_collections_url, flash: { 
            danger: "组合正在使用，无法删除" } and return
        end
        
        if @collection.products.count>0
          redirect_to admin_collections_url, flash: { 
            danger: "组合正在使用，无法删除" } and return
        end

        @collection.update(is_destroy:true)
        redirect_to admin_collections_url, flash: { success: "组合已删除" }
    end

    private
    # Using a private method to encapsulate the permissible parameters is
    # just a good pattern since you'll be able to reuse the same permit
    # list between create and update. Also, you can specialize this method
    # with per-user checking of permissible attributes.
    def collection_params
        params.require(:collection).permit :name, :description, :landing_page_html, :donation_percentage, :picture, :active, :sort_order
    end

end
