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

end
