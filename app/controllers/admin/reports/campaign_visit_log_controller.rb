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
      endate= Time.now.strftime("%Y-%m-%d") +" 23:59:59"
    end

    @fromdate=fromdate
    @todate=endate


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


    from_date=Time.parse(from_date).strftime("%Y-%m-%d")
    to_date=Time.parse(to_date).strftime("%Y-%m-%d")+" 23:59:59"

    logger.debug "1001:"
    logger.debug campagin_id.to_i
    if campagin_id.to_i<1
      @results=CampaignVisitLog.where("visited_time >= :start_date AND visited_time < :end_date",
                                                                         {start_date:from_date,end_date: to_date}).includes(:campaign).order(:id=>:desc).page(params[:page])
      @total=CampaignVisitLog.where("visited_time >= :start_date AND visited_time < :end_date",
                                    {start_date:from_date,
                                     end_date: to_date}).count
    else
      @results=CampaignVisitLog.where(:campaign_id => campagin_id).where("visited_time >= :start_date AND visited_time < :end_date",
                                                                         {start_date:from_date,end_date: to_date}).includes(:campaign).order(:id=>:desc).page(params[:page])
      @total=CampaignVisitLog.where(:campaign_id => campagin_id).where("visited_time >= :start_date AND visited_time < :end_date",
                                    {start_date:from_date,
                                     end_date: to_date}).count
    end

    # logger.debug @results.to_yaml ·
    # ids=@results.collect(&:campaign_id)
    # @campagins=Campaign.all.where(id:ids)


    render :partial=>"report_content"
  end

end
