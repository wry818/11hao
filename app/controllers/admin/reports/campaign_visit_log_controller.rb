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

    @results=CampaignVisitLog.where("visited_time +'8 H' >= :start_date AND visited_time +'8 H' < :end_date",
                                    {start_date:fromdate,
                                     end_date:endate}).includes(:campaign).order(:id=>:desc).page(params[:page])

    # logger.debug @results.to_yaml
    # ids=@results.collect(&:campaign_id)
    # @campagins=Campaign.all.where(id:ids)
    @total=CampaignVisitLog.where("visited_time +'8 H' >= :start_date AND visited_time +'8 H' < :end_date",
                                  {start_date:fromdate,
                                   end_date:endate}).count

  end

  def reportsearch

    logger.debug "1001...................:"
    logger.debug Time.zone

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
      @results=@results.where("visited_time +'8 H' >= ?",from_date)
    end
    if to_date.length>0
      @results=@results.where("visited_time +'8 H' < ?",to_date)
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
    event_id=params[:event_id];

    if from_date.length>0
      from_date=Time.parse(from_date).strftime("%Y-%m-%d")
    end
    if to_date.length>0
      to_date=Time.parse(to_date).strftime("%Y-%m-%d")+" 23:59:59"
    end

    @campaigns=Campaign.isnot_destroy.order(:id=>:desc)
    if event_id&&event_id.length>0&&event_id!="-1"
      @campaigns=@campaigns.where(:fundraising_event_id=>event_id)
    end
    if campagin_id.to_i>=0
      @campaigns=@campaigns.where(:campaign_id => campagin_id)
    end

    @results=Array.new

    @campaigns.each do |campaign_temp|
      logger.debug "-----------------begin"
      # log---------------------------------------------------
      @result_item=Hash.new
      @count_log=CampaignVisitLog.where(:campaign_id => campaign_temp.id)
      if from_date.length>0
        @count_log=@count_log.where("visited_time+'8 H' >= ?",from_date)
      end
      if to_date.length>0
        @count_log=@count_log.where("visited_time +'8 H' < ?",to_date)
      end
      @result_item["id"]=campaign_temp.id
      @result_item["title"]=campaign_temp.title
      @result_item["log_count"]=@count_log.count
      # share-----------------------------------------------------------------
      @share_log=SellerReferral.joins(:seller).where(:sellers=>{:campaign_id =>campaign_temp.id })
      if from_date.length>0
        @share_log=@share_log.where("seller_referrals.updated_at+'8 H' >= ?",from_date)
      end
      if to_date.length>0
        @share_log=@share_log.where("seller_referrals.updated_at+'8 H' < ?",to_date)
      end
      @result_item["share_count"]=@share_log.count
      # ordrs-----------------------------------------------------------------------
      @order_log=Order.where(:campaign_id => campaign_temp.id).where("direct_donation>0").completed
      if from_date.length>0
        @order_log=@order_log.where("updated_at+'8 H' >= ?",from_date)
      end
      if to_date.length>0
        @order_log=@order_log.where("updated_at+'8 H' < ?",to_date)
      end
      @result_item["order_count"]=@order_log.count

      # max orders page  orders.count------------------------------------------------------
     logger.debug "2002"
      query = QueryHelper.get_page_orders_countmax(campaign_temp.id)
      page_orders_max = ActiveRecord::Base.connection.execute(query)
      if page_orders_max&&page_orders_max.count>0
        @result_item["page_orders_max"]=page_orders_max[0]["max"]==nil ? "0" :page_orders_max[0]["max"]
      else
        @result_item["page_orders_max"]=0
      end
      # avg orders
      query = QueryHelper.get_page_orders_countavg(campaign_temp.id)
      page_orders_avg = ActiveRecord::Base.connection.execute(query)
      if page_orders_avg&&page_orders_avg.count>0
        @result_item["page_orders_avg"]=page_orders_avg[0]["avg"]==nil ? "0" :page_orders_avg[0]["avg"].to_i
      else
        @result_item["page_orders_avg"]=0
      end
      # 100 1000 10000visit_log--------------------------------------------------------------
      @log_time_offset=CampaignVisitLog.where(:campaign_id => campaign_temp.id)
      if from_date.length>0
        @log_time_offset=@log_time_offset.where("visited_time+'8 H' >= ?",from_date)
      end
      if to_date.length>0
        @log_time_offset=@log_time_offset.where("visited_time+'8 H' < ?",to_date)
      end
       @log_time_offsettemp=@log_time_offset.order("visited_time").limit(1).offset(100).first
       if @log_time_offsettemp
         @result_item["log_time_offset100"]=@log_time_offsettemp.visited_time.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s
       end
      @log_time_offsettemp=@log_time_offset.order("visited_time").limit(1).offset(1000).first
      if @log_time_offsettemp
        @result_item["log_time_offset1000"]=@log_time_offsettemp.visited_time.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s
      end
      @log_time_offsettemp=@log_time_offset.order("visited_time").limit(1).offset(10000).first
      if @log_time_offsettemp
        @result_item["log_time_offset10000"]=@log_time_offsettemp.visited_time.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s
      end
      # 100 1000 10000 order time---------------------------------------------------------
      @log_orders_offset=Order.where(:campaign_id => campaign_temp.id).completed
      if from_date.length>0
        @log_orders_offset=@log_orders_offset.where("updated_at+'8 H' >= ?",from_date)
      end
      if to_date.length>0
        @log_orders_offset=@log_orders_offset.where("updated_at+'8 H' < ?",to_date)
      end
      @log_orders_offsettemp=@log_orders_offset.order("updated_at").limit(1).offset(100).first
      if @log_orders_offsettemp
        @result_item["log_orders_offset100"]=@log_orders_offsettemp.updated_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s
      end
      @log_orders_offsettemp=@log_orders_offset.order("updated_at").limit(1).offset(1000).first
      if @log_orders_offsettemp
        @result_item["log_orders_offset1000"]=@log_orders_offsettemp.updated_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s
      end
      @log_orders_offsettemp=@log_orders_offset.order("updated_at").limit(1).offset(10000).first
      if @log_orders_offsettemp
        @result_item["log_orders_offset10000"]=@log_orders_offsettemp.updated_at.localtime.strftime('%Y-%m-%d %H:%M:%S').to_s
      end

      @results<<@result_item
    end

    render :partial=>"visit_share_donation_content"
  end

  def report_visit_log
    if params[:from_date]
      fromdate=Time.parse(params[:from_date]).strftime("%Y-%m-%d")
    else
      fromdate=(Time.now-+ (60 * 60 * 24*1)).strftime("%Y-%m-%d")
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
  def report_visit_log_ajax
    campagin_id=params[:campagin_id];
    from_date=params[:from_date];
    to_date=params[:to_date];
    event_id=params[:event_id];

    if from_date.length>0
      from_date=Time.parse(from_date).strftime("%Y-%m-%d")
    end
    if to_date.length>0
      to_date=Time.parse(to_date).strftime("%Y-%m-%d")+" 23:59:59"
    end
    query=""

    if event_id=="1"
      query = QueryHelper.get_visit_log_reort(campagin_id,from_date,to_date,"YYYY-MM-DD HH24")
    end
    if event_id=="2"
      query = QueryHelper.get_visit_log_reort(campagin_id,from_date,to_date,"YYYY-MM-DD")
    end
    if event_id=="3"
      query = QueryHelper.get_visit_log_reort(campagin_id,from_date,to_date,"YYYY-MM")
    end
    if event_id=="4"
      query = QueryHelper.get_visit_log_reort(campagin_id,from_date,to_date,"YYYY")
    end

    @results = ActiveRecord::Base.connection.execute(query)
    @total_log=0
    @total_order=0
    render :partial=>"report_visit_log_content"
  end
end
