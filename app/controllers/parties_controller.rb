class PartiesController < ApplicationController
  before_filter :authenticate_user!
  def index

    @parties=Party.where(:user_id => current_user.id).order(id: :desc)
    if admin_user?
      @parties=Party.order(id: :desc);
    end
  end

  def new
   @party=Party.new

  end

  def create
    @party = Party.new party_params
    @party.user_id=current_user.id
    if params[:address]
      ads=params[:address].split('/')
      ads.each_with_index do |item,i |
        if i==0
          @party.provice=item
        elsif i==1
          @party.city=item
        elsif i==2
          @party.country=item
        end
      end
    end
    if params[:optionsRadiosfee]
      if params[:optionsRadiosfee]=="option1"
        if params[:max_count]
          @party.has_fee=false;
          @party.max_count=params[:max_count].to_i
        end
      elsif params[:optionsRadiosfee]=="option2"
        if params[:fee_count]
          @party.fee_count=params[:fee_count].to_f*100
        end
        # if params[:tickets][:item]
        #   titem=params[:tickets][:item]
        #   if titem[:type]
        #     titem[:type]
        #   end
        # end

      end
    end

    @party.save
    redirect_to party_preview_path(@party) and return
  end
  def party_preview

    @party=Party.find(params[:id]);
    url=Rails.configuration.url_host+party_index_weixin_path("party_#{@party.id}")
    if Rails.env.test?||Rails.env.development?
      url=party_index_weixin_url("party_#{@party.id}")
    end
    # url= ERB::Util.url_encode(url)
    logger.debug "1001:"+url

    qr = RQRCode::QRCode.new(url, :size => 10, :level => :h)

    @qr_url = qr.to_img.resize(200, 200).to_data_url
    @http_url=url
  end
  def party_orders
    @party=Party.find(params[:id]);
    url=Rails.configuration.url_host+party_index_weixin_path("party_#{@party.id}")
    if Rails.env.test?||Rails.env.development?
      url=party_index_weixin_url("party_#{@party.id}")
    end
    # url= ERB::Util.url_encode(url)
    logger.debug "1001:"+url

    qr = RQRCode::QRCode.new(url, :size => 10, :level => :h)

    @qr_url = qr.to_img.resize(200, 200).to_data_url
    @http_url=url
  end

  def edit
    @party=Party.find(params[:id])
  end
  def update
    @party=Party.find(params[:id])

    @party.assign_attributes party_params

    if !admin_user?
      @party.user_id=current_user.id
    end
    if params[:address]
      ads=params[:address].split('/')
      ads.each_with_index do |item,i |
        if i==0
          @party.provice=item
        elsif i==1
          @party.city=item
        elsif i==2
          @party.country=item
        end
      end
    end
    if params[:optionsRadiosfee]
      if params[:optionsRadiosfee]=="option1"
        if params[:max_count]
          @party.has_fee=false
          @party.max_count=params[:max_count].to_i
        end
      elsif params[:optionsRadiosfee]=="option2"
        if params[:fee_count]
          @party.has_fee=true
          @party.fee_count=params[:fee_count].to_f*100
        end
        # if params[:tickets][:item]
        #   titem=params[:tickets][:item]
        #   if titem[:type]
        #     titem[:type]
        #   end
        # end

      end
    end

    @party.save
    redirect_to party_preview_path(@party) and return
  end
  private
  def party_params
    params.require(:party).permit :name,:begin_time,:end_time,:register_end,:address,:content
  end
end
