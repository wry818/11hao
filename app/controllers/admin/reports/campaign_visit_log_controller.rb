class Admin::Reports::CampaignVisitLogController < Admin::Reports::ApplicationController

  def reportindex
    sql_count="select count(1) as total FROM
              \"public\".campaign_visit_logs
              LEFT JOIN campaigns on campaign_visit_logs.campaign_id=campaigns.\"id\""
    sql="SELECT
              campaign_visit_logs.\"id\",
              campaign_visit_logs.campaign_id,
              campaign_visit_logs.seller_id,
              campaign_visit_logs.remote_ip,
              campaign_visit_logs.visited_time,
              campaign_visit_logs.nickname,
              campaign_visit_logs.open_id,
              campaigns.title
              FROM
              \"public\".campaign_visit_logs
              LEFT JOIN campaigns on campaign_visit_logs.campaign_id=campaigns.\"id\" "
    sqlwhere=" where 1=1 and campaign_visit_logs.visited_time>='"+(Time.now-+ (60 * 60 * 24*7)).strftime("%Y-%m-%d")+"'"
    sqlwhere+=" and campaign_visit_logs.visited_time<'"+Time.now.strftime("%Y-%m-%d")+"'"
    @total=CampaignVisitLog.find_by_sql(sql_count+sqlwhere).first
    @results=CampaignVisitLog.find_by_sql(sql+sqlwhere+" order by id desc")
  end

  def reportsearch

    campagin_id=params[:campagin_id];
    from_date=params[:from_date];
    to_date=params[:to_date];

    logger.debug params.inspect
    sql_count="select count(1) as total FROM
              \"public\".campaign_visit_logs
              LEFT JOIN campaigns on campaign_visit_logs.campaign_id=campaigns.\"id\" where 1=1"
    sql ="SELECT
              campaign_visit_logs.\"id\",
              campaign_visit_logs.campaign_id,
              campaign_visit_logs.seller_id,
              campaign_visit_logs.remote_ip,
              campaign_visit_logs.visited_time,
              campaign_visit_logs.nickname,
              campaign_visit_logs.open_id,
              campaigns.title
              FROM
              \"public\".campaign_visit_logs
              LEFT JOIN campaigns on campaign_visit_logs.campaign_id=campaigns.\"id\" where 1=1 "
    sqlwhere=""
    if campagin_id.to_i>0
      sqlwhere+=" and campaign_visit_logs.campaign_id="+campagin_id
    end
    sqlwhere+=" and campaign_visit_logs.visited_time>='"+from_date+"'"
    sqlwhere+=" and campaign_visit_logs.visited_time<'"+to_date+"'"

    @total=CampaignVisitLog.find_by_sql(sql_count+sqlwhere).first

    @results=CampaignVisitLog.find_by_sql(sql+sqlwhere+" order by id desc")

    render :partial=>"report_content"
  end

end
