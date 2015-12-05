class Admin::ProductCategoriesController < Admin::ApplicationController

  def index
    @product_categories=ProductCategory.isnot_destroy
  end

  def new
    @product_category = ProductCategory.new
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
      redirect_to admin_product_categories_path
    else
      render action: :new
    end
  end



  def show

  end

  def destroy
    @product_category=ProductCategory.find(params[:id])

    @product_category.update(is_destroy:true)

    redirect_to admin_product_categories_path, flash: { success: "商品类别已删除" }
  end


  def product_category_params
    params.require(:product_category).permit :name,:sort_mark,:active
  end
end
