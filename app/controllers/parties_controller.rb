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
        @party.has_fee=false;
        @party.fee_count=0
        if params[:max_count]
          @party.max_count=params[:max_count].to_i
        end
      elsif params[:optionsRadiosfee]=="option2"
        @party.has_fee=true;
        if params[:max_count]
          @party.max_count=params[:max_count].to_i
        end
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
    @party.begin_time=@party.begin_time.strftime('%Y-%m-%d %H:%M')
    @party.end_time=@party.end_time.strftime('%Y-%m-%d %H:%M')
    @party.register_end=@party.begin_time.strftime('%Y-%m-%d %H:%M')
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
        @party.has_fee=false;
        @party.fee_count=0
        if params[:max_count]
          @party.max_count=params[:max_count].to_i
        end
      elsif params[:optionsRadiosfee]=="option2"
        @party.has_fee=true;
        if params[:max_count]
          @party.max_count=params[:max_count].to_i
        end
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


  def party_orders_ajax
    @party=Party.find(params[:id])
    order_type_flag=params[:order_type_flag];
    from_date=params[:from_date];
    to_date=params[:to_date];


    if from_date.length>0
      from_date=Time.parse(from_date).strftime("%Y-%m-%d")
    end
    if to_date.length>0
      to_date=Time.parse(to_date).strftime("%Y-%m-%d")+" 23:59:59"
    end

    logger.debug "1001:"

    @results=@party.participants.completed.order(:id=>:desc)

    if order_type_flag.to_s.length>0

        @results=@results.where("name like ?", "%#{order_type_flag}%" )
    end
    if from_date.length>0
      @results=@results.where("participants.updated_at +'8 H' >= ?",from_date)
    end
    if to_date.length>0
      @results=@results.where("participants.updated_at +'8 H' <= ?",to_date)
    end

    logger.debug 1002
    @total=@results.count
    @saled_count=(@results.joins("JOIN orders ON participants.orders_id = orders.id").sum('orders.direct_donation') ) / 100.0
    @results=@results.page(params[:page])

    render :partial=>"orders_list"
  end
  def party_orders_download
    @party=Party.find(params[:id])
    order_type_flag=params[:order_type_flag];
    from_date=params[:from_date];
    to_date=params[:to_date];


    if from_date.length>0
      from_date=Time.parse(from_date).strftime("%Y-%m-%d")
    end
    if to_date.length>0
      to_date=Time.parse(to_date).strftime("%Y-%m-%d")+" 23:59:59"
    end

    logger.debug "1001:"

    @results=@party.participants.completed.order(:id=>:desc)

    if order_type_flag.to_s.length>0

      @results=@results.where("name like ?", "%#{order_type_flag}%" )
    end
    if from_date.length>0
      @results=@results.where("participants.updated_at +'8 H' >= ?",from_date)
    end
    if to_date.length>0
      @results=@results.where("participants.updated_at +'8 H' <= ?",to_date)
    end

    logger.debug 1002
    @total=@results.count
    @saled_count=(@results.joins("JOIN orders ON participants.orders_id = orders.id").sum('orders.direct_donation') ) / 100.0

    render xlsx: "party_orders_download", filename: "orders.xlsx"
  end
  private
  def party_params
    params.require(:party).permit :name,:begin_time,:end_time,:register_end,:address,:content,:logo,:allow_spread
  end
end
