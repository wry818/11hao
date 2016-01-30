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
end