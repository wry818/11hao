class Admin::Reports::CampaignVisitLogController < Admin::Reports::ApplicationController

  def reportindex
    # sql_count="select count(1) as total FROM
    #           \"public\".campaign_visit_logs
    #           LEFT JOIN campaigns on campaign_visit_logs.campaign_id=campaigns.\"id\""
    # sql="SELECT
    #           campaign_visit_logs.\"id\",
    #           campaign_visit_logs.campaign_id,
    #           campaign_visit_logs.seller_id,
    #           campaign_visit_logs.remote_ip,
    #           campaign_visit_logs.visited_time,
    #           campaign_visit_logs.nickname,
    #           campaign_visit_logs.open_id,
    #           campaigns.title
    #           FROM
    #           \"public\".campaign_visit_logs
    #           LEFT JOIN campaigns on campaign_visit_logs.campaign_id=campaigns.\"id\" "
    # sqlwhere=" where 1=1 and campaign_visit_logs.visited_time>='"+(Time.now-+ (60 * 60 * 24*7)).strftime("%Y-%m-%d")+"'"
    # sqlwhere+=" and campaign_visit_logs.visited_time<'"+Time.now.strftime("%Y-%m-%d")+"'"
    # @total=CampaignVisitLog.find_by_sql(sql_count+sqlwhere).first
    # @results=CampaignVisitLog.find_by_sql(sql+sqlwhere+" order by id desc")

    logger.debug Time.now.to_s

    if params[:from_date]
      fromdate=Time.parse(params[:from_date]).strftime("%Y-%m-%d")
    else
      fromdate=(Time.now-+ (60 * 60 * 24*7)).strftime("%Y-%m-%d")
    end

    if params[:to_date]
      endate=Time.parse(params[:to_date]).strftime("%Y-%m-%d")
    else
      endate= Time.now.strftime("%Y-%m-%d")
    end

    @fromdate=fromdate
    @todate=endate
    endate+=" 23:59:59"

    @results=CampaignVisitLog.where("visited_time >= :start_date AND visited_time < :end_date",
                                    {start_date:fromdate,
                                     end_date:endate}).includes(:campaign).order(:id=>:desc).page(params[:page])

    # logger.debug @results.to_yaml
    # ids=@results.collect(&:campaign_id)
    # @campagins=Campaign.all.where(id:ids)
    @total=CampaignVisitLog.where("visited_time >= :start_date AND visited_time < :end_date",
                                  {start_date:fromdate,
                                   end_date:endate}).count

  end

  def reportsearch

    campagin_id=params[:campagin_id];
    from_date=params[:from_date];
    to_date=params[:to_date];


    if from_date.length>0
      from_date=Time.parse(from_date).strftime("%Y-%m-%d")
    end
    if to_date.length>0
      to_date=Time.parse(to_date).strftime("%Y-%m-%d")+" 23:59:59"
    end

    logger.debug "1001:"
    logger.debug campagin_id
    logger.debug campagin_id.to_i

    @results=CampaignVisitLog.includes(:campaign).order(:id=>:desc)

    if campagin_id.to_i>=0
      @results=@results.where(:campaign_id => campagin_id)
    end
    if from_date.length>0
      @results=@results.where("visited_time >= ?",from_date)
    end
    if to_date.length>0
      @results=@results.where("visited_time < ?",to_date)
    end

    logger.debug 1002
    @total=@results.count
    @results=@results.page(params[:page])

    render :partial=>"report_content"
  end

  def visit_share_donation
    if params[:from_date]
      fromdate=Time.parse(params[:from_date]).strftime("%Y-%m-%d")
    else
      fromdate=(Time.now-+ (60 * 60 * 24*7)).strftime("%Y-%m-%d")
    end

    if params[:to_date]
      endate=Time.parse(params[:to_date]).strftime("%Y-%m-%d")
    else
      endate= Time.now.strftime("%Y-%m-%d")
    end

    @fromdate=fromdate
    @todate=endate
    endate+=" 23:59:59"
  end
  def visit_share_donation_ajax
    campagin_id=params[:campagin_id];
    from_date=params[:from_date];
    to_date=params[:to_date];


    if from_date.length>0
      from_date=Time.parse(from_date).strftime("%Y-%m-%d")
    end
    if to_date.length>0
      to_date=Time.parse(to_date).strftime("%Y-%m-%d")+" 23:59:59"
    end

    @campaigns=Campaign.order(:id=>:desc)
    if campagin_id.to_i>=0
      @campaigns=@campaigns.where(:campaign_id => campagin_id)
    end
    # if from_date.length>0
    #   @results=@results.where("visited_time >= ?",from_date)
    # end
    # if to_date.length>0
    #   @results=@results.where("visited_time < ?",to_date)
    # end
    @results=Array.new

    @campaigns.each do |campaign_temp|
      # log
      @result_item=Hash.new
      @count_log=CampaignVisitLog.where(:campaign_id => campaign_temp.id)
      if from_date.length>0
        @count_log=@count_log.where("visited_time >= ?",from_date)
      end
      if to_date.length>0
        @count_log=@count_log.where("visited_time < ?",to_date)
      end
      @result_item["id"]=campaign_temp.id
      @result_item["title"]=campaign_temp.title
      @result_item["log_count"]=@count_log.count
      # share

      seller_ids=campaign_temp.sellers.collect(&:id)
      @share_log=SellerReferral.where(:is_success => true,:seller_id => seller_ids)
      if from_date.length>0
        @share_log=@share_log.where("updated_at >= ?",from_date)
      end
      if to_date.length>0
        @share_log=@share_log.where("updated_at < ?",to_date)
      end
      @result_item["share_count"]=@share_log.count
      # ordrs
      @order_log=Order.where(:campaign_id => campaign_temp.id).completed
      if from_date.length>0
        @order_log=@order_log.where("updated_at >= ?",from_date)
      end
      if to_date.length>0
        @order_log=@order_log.where("updated_at < ?",to_date)
      end
      @result_item["order_count"]=@order_log.count

      # max orders page  orders.count

     logger.debug "2002"
     # @page_orders_max=Order.select("count(seller_id)").having(:campaign_id => campaign_temp.id,:status=>[1,3]).group("seller_id")

      # avg orders



      @results<<@result_item
    end




    render :partial=>"visit_share_donation_content"
  end
end
