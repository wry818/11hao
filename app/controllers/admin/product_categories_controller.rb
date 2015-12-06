class Admin::ProductCategoriesController < Admin::ApplicationController

  def index
    @product_categories=ProductCategory.isnot_destroy.order(:sort_mark)
  end

  def new
    @product_category = ProductCategory.new
  end

  def subclassnew
    logger.debug("1001subclassnew")
    @product_category = ProductCategory.find(params[:product_category_id])
    @product_category=@product_category.product_categories.new
  end
  def create
    @product_category=ProductCategory.new(product_category_params)

    if !@product_category.valid?
      message = ''
      @product_category.errors.each do |key, error|
        message = message + error.to_s + ', '
      end
      flash.now[:danger] = message[0...-2]
      render action: "new" and return
    end

    if @product_category.save
      redirect_to admin_product_categories_path,flash: { success: "商品类别已保存" }
    else
      render action: :new
    end
  end

  def subclasscreate
    product_category = ProductCategory.find(params[:product_category_id])
    @product_category=product_category.product_categories.new(product_category_params)
    if !@product_category.valid?
      message = ''
      @product_category.errors.each do |key, error|
        message = message + error.to_s + ', '
      end
      flash.now[:danger] = message[0...-2]
      render action: "subclassnew" and return
    end

    if @product_category.save
      redirect_to admin_product_category_path(product_category),flash: { success: "子类别已保存" }
    else
      render action: :subclassnew
    end
  end

  def edit
    @product_category = ProductCategory.find(params[:id])
  end

  def subclassedit
    @product_category = ProductCategory.find(params[:id])
  end
  def update
    @product_category=ProductCategory.find(params[:id])
    @product_category.assign_attributes(product_category_params)

    if !@product_category.valid?
      message = ''
      @product_category.errors.each do |key, error|
        message = message + error.to_s + ', '
      end
      flash.now[:danger] = message[0...-2]
      render action: "edit" and return
    end

    if @product_category.save
      redirect_to admin_product_categories_path,flash: { success: "商品类别已修改" }
    else
      render action: :edit
    end
  end
  def subclassupdate
    @product_category=ProductCategory.find(params[:id])
    @product_category.assign_attributes(product_category_params)

    if !@product_category.valid?
      message = ''
      @product_category.errors.each do |key, error|
        message = message + error.to_s + ', '
      end
      flash.now[:danger] = message[0...-2]
      render action: "subclassnew" and return
    end

    if @product_category.save
      redirect_to admin_product_category_path(@product_category.product_category),flash: { success: "子类别已修改" }
    else
      render action: :subclassnew
    end
  end
  def show
    if params.has_key?(:id)
      @product_category=ProductCategory.find(params[:id]) and return
    end
    else if  params.has_key?(:product_category_id)
         @product_category=ProductCategory.find(params[:product_category_id])
    end

  end

  def subclassshow
    @product_category=ProductCategory.find(params[:product_category_id])
    @product_category_subclass=@product_category.product_categories
  end

  def destroy
    @product_category=ProductCategory.find(params[:id])

    @product_category.update(is_destroy:true)

    redirect_to admin_product_categories_path, flash: { success: "商品类别已删除" }
  end
  def subclassdestroy
    @product_category=ProductCategory.find(params[:id])

    @product_category.update(is_destroy:true)

    redirect_to admin_product_category_path(@product_category.product_category), flash: { success: "子类别已删除" }

  end



  def product_category_params
    params.require(:product_category).permit :name,:sort_mark,:active
  end
end
