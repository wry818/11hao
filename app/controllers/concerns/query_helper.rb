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
    limit_line=""
    if date_time.length>0
      where_time=" and updated_at>'"+date_time+"'"
      limit_line=" LIMIT 1"
    end
    query="select rank() over (order by all_count desc) as rank, a.*,campaigns.*
          from
          (
            SELECT campaigns.id,COALESCE (sum(o.id), 0),count(o.id) as all_count FROM (SELECT * from orders where status=3 and direct_donation>0"+where_time+") o
            RIGHT JOIN campaigns  on campaigns.id=o.campaign_id
            where campaigns.id in ("+campagin_ids+")
            GROUP BY campaigns.id
            order  by all_count DESC,id DESC
          ) a
          inner JOIN   campaigns on a.ID=campaigns.id "
  end

  def self.get_seller_ladder_campaign(campagin_ids)
    query="select rank() over (order by sum desc) as rank, a.*, sellers.referral_code, users.uid, user_profiles.first_name, user_profiles.picture from
    (
						SELECT
						w. ID,
						w.user_profile_id,
						SUM (
							COALESCE (o.direct_donation, 0)
						) ,
						COUNT (o. ID)
					FROM
						 sellers w
					LEFT JOIN (
						SELECT o1.id id,o1.direct_donation,o1.seller_id FROM orders o1
		where o1.status=3
						UNION ALL
						(
							SELECT o2.id id,o2.direct_donation,w.id as seller_id FROM orders o2
							INNER JOIN
							(
							SELECT DISTINCT t1.id,t3.seller_id as seller_id from sellers t1
							INNER JOIN seller_referrals t2 on t1.id=t2.seller_id
							INNER join seller_referrals t3 on t2.id=t3.sellerreferral_id
							WHERE t1.campaign_id in("+campagin_ids+") and t1.id!=t3.seller_id
							)w on o2.seller_id=w.seller_id and o2.status=3
						)
					) o ON w.ID = o.seller_id
					WHERE
						w.campaign_id IN ("+campagin_ids+")
					GROUP BY
						w.ID,
						w.user_profile_id
         limit 1000
    ) a
    inner join user_profiles on a.user_profile_id = user_profiles.id
    inner join users on user_profiles.user_id = users.id
    inner join sellers on a.id = sellers.id"
  end

  def self.get_seller_ladder_campaign_today(campagin_ids)
    query="select rank() over (order by sum desc) as rank, a.*, sellers.referral_code, users.uid, user_profiles.first_name, user_profiles.picture from
    (
						SELECT
						w. ID,
						w.user_profile_id,
						SUM (
							COALESCE (o.direct_donation, 0)
						) ,
						COUNT (o. ID)
					FROM
					 sellers w
					LEFT JOIN (
						SELECT o1.id id,o1.direct_donation,o1.seller_id FROM orders o1
          where o1.updated_at >'"+Time.now.to_date.to_s+"' and o1.status=3
						UNION ALL
						(
							SELECT o2.id id,o2.direct_donation,w.id as seller_id FROM orders o2
							INNER JOIN
							(
							SELECT DISTINCT t1.id,t3.seller_id as seller_id from sellers t1
							INNER JOIN seller_referrals t2 on t1.id=t2.seller_id
							INNER join seller_referrals t3 on t2.id=t3.sellerreferral_id
							WHERE t1.campaign_id in("+campagin_ids+") and t1.id!=t3.seller_id

							)w on o2.seller_id=w.seller_id and o2.status=3
            where o2.updated_at >'"+Time.now.to_date.to_s+"'
						)
					) o ON w.ID = o.seller_id
					WHERE
						w.campaign_id IN ("+campagin_ids+")
					GROUP BY
						w.ID,
						w.user_profile_id
          limit 100
    ) a
    inner join user_profiles on a.user_profile_id = user_profiles.id
    inner join users on user_profiles.user_id = users.id
    inner join sellers on a.id = sellers.id"
  end
end