class QueryHelper
  
  def self.get_seller_ladder(campaign_id, campaign_mode)
    
    order_column = ""
    
    if campaign_mode == Campaign::Fundraising
      
      order_column = "a.sum"
      
    else
      
      order_column = "a.count"
      
    end
    
    query = "
    select rank() over (order by " + order_column + " desc) as rank, a.*, sellers.referral_code, users.uid, user_profiles.first_name, user_profiles.picture from
    (
      select 

    	  sellers.id, sellers.user_profile_id, sum(COALESCE(items.quantity * items.donation_amount + orders.direct_donation, 0)), count(orders.id)

      from sellers 

      left join orders on sellers.id = orders.seller_id

      left join items on items.order_id = orders.id

      where sellers.campaign_id = " + campaign_id.to_s + " 

      group by sellers.id, sellers.user_profile_id

      limit 10000
      
    ) a
    inner join user_profiles on a.user_profile_id = user_profiles.id
    inner join users on user_profiles.user_id = users.id
    inner join sellers on a.id = sellers.id
    
    "
    
  end

  def self.get_ladder_campaign(campagin_ids,date_time)
    where_time=""
    if date_time.length>0
      where_time=" and updated_at>'"+date_time+"'"
    end
    query="select rank() over (order by all_count desc) as rank, a.*,campaigns.*
          from
          (
            SELECT campaigns.id,COALESCE (sum(o.id), 0),count(o.id) as all_count FROM (SELECT * from orders where status=3 and direct_donation>0"+where_time+") o
            INNER JOIN sellers s on o.seller_id=s.id
            RIGHT JOIN campaigns  on campaigns.id=s.campaign_id
            where campaigns.id in ("+campagin_ids+")
            GROUP BY campaigns.id
          ) a
          inner JOIN   campaigns on a.ID=campaigns.id"
  end

  def self.get_page_orders_countmax(campagin_id)
    query="SELECT MAX(count) from
          (
            SELECT  count(o.seller_id) FROM
            (
                  SELECT * from orders where orders.campaign_id = "+campagin_id.to_s+"
                  AND orders.status IN (1, 3)
                  and COALESCE(orders.seller_id,-1)>0

            ) o
            GROUP BY o.seller_id
          ) w
          "
  end

  def self.get_page_orders_countavg(campagin_id)
    query="SELECT avg(count) from
          (
            SELECT  count(o.seller_id) FROM
            (
                  SELECT * from orders where orders.campaign_id = "+campagin_id.to_s+"
                  AND orders.status IN (1, 3)
                  and COALESCE(orders.seller_id,-1)>0

            ) o
            GROUP BY o.seller_id
          ) w
          "
  end

  def self.get_visit_log_reort(campaign_id,time_start,time_end,group_type)
    where_temp=""
    where_temp_order=""
    if campaign_id&&campaign_id.length>0&&campaign_id!="-1"
      where_temp+=" and campaign_visit_logs.campaign_id="+campaign_id
      where_temp_order+=" and orders.campaign_id="+campaign_id
    end
    if time_start&&time_start.length>0
      where_temp+=" and campaign_visit_logs.visited_time AT TIME ZONE 'CCT'>='"+time_start+"'"
      where_temp_order+=" and orders.updated_at AT TIME ZONE 'CCT'>='"+time_start+"'"
    end
    if time_end&&time_end.length>0
      where_temp+=" and campaign_visit_logs.visited_time AT TIME ZONE 'CCT'<'"+time_end+"'"
      where_temp_order+=" and orders.updated_at AT TIME ZONE 'CCT'<'"+time_end+"'"
    end
     query="SELECT
           CASE when v.d is NULL then w.d ELSE v.d end as d,
           COALESCE(v.log_count,0) log_count,
           COALESCE(w.order_count,0) order_count
           FROM
          (
            SELECT
             to_char(
             campaign_visit_logs.visited_time AT TIME ZONE 'CCT',
             '"+group_type+"'
             ) AS d,
             COUNT(1) as log_count
             FROM
             campaign_visit_logs
             WHERE 1=1 "+where_temp+"
             GROUP BY
             d
             ORDER BY
             d desc
          ) v
          FULL JOIN
          (
            SELECT
             to_char(
             orders.updated_at AT TIME ZONE 'CCT',
             '"+group_type+"'
             ) AS d,
             COUNT(1) as order_count
             FROM
             orders
             WHERE 1=1 "+where_temp_order+"
             GROUP BY
             d
             ORDER BY
             d desc
          ) w  on  v.d=w.d

"
  end
end