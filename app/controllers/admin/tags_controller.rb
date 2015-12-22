class Admin::TagsController < Admin::ApplicationController
  def index
    # @tags=Tag.isnot_destroy.order(:updated_at => :desc).page(params[:page])
  end

  def ajax_pager_data
    @tags=Tag.isnot_destroy.where("name like ?", "%#{params[:name]}%").order(:updated_at => :desc).page(params[:page])

    render partial: "table_show"
  end
  def search_ajax
    if params[:tag_name]!=nil&&params[:tag_name]!=""
      @tag=Tag.find_by_name(params[:tag_name]);
      if @tag
        @tag.updated_at=Time.now;
        @tag.save
      else
        @tag=Tag.new();
        @tag.name=params[:tag_name];
        @tag.active=true;
        @tag.is_destroy=false;
        @tag.save
      end
    end
    @tags=Tag.is_active.isnot_destroy.order(:updated_at => :desc).limit(50)
    #
    # @tags=Tag.is_active.isnot_destroy.where("name like ?",
    #                                         "%#{params[:tag_name]}%").order(:updated_at => :desc).limit(50)
    render partial: "tags_show"
  end
  def ajax_delete
    @tag=Tag.find(params[:tag_id]);
    # @tag.product_tagses.clear
    @tag.destroy
    render text: "ok"
  end


  def new
    @tag=Tag.new
  end

  def create
    @tag=Tag.new(tag_params)

    if !@tag.valid?
      message = ''
      @tag.errors.each do |key, error|
        message = message + error.to_s + ', '
      end
      flash.now[:danger] = message[0...-2]
      render action: "new" and return
    end

    if @tag.save
      redirect_to admin_tags_path, flash: {success: "标签已保存"}
    else
      render action: :new
    end
  end

  def update
    @tag=Tag.find(params[:id]);
    @tag.assign_attributes(tag_params);

    if !@tag.valid?
      message = ''
      @tag.errors.each do |key, error|
        message = message + error.to_s + ', '
      end
      flash.now[:danger] = message[0...-2]
      render action: "edit" and return
    end

    if @tag.save
      redirect_to admin_tags_path, flash: {success: "标签已保存"}
    else
      render action: :edit
    end
  end

  def edit
    @tag=Tag.find(params[:id]);
  end
  def show

  end
  def destroy
    @tag=Tag.find(params[:id])

    @tag.update(is_destroy:true)

    redirect_to admin_tags_path, flash: { success: "标签类别已删除" }
  end


  private
  def tag_params
    params.require(:tag).permit :name, :active, :starmark, :search_help
  end
end
