class QueryHelper
  
  def self.get_seller_ladder(campaign_id)
    
    query = "
    select ROW_NUMBER() over (order by a.sum desc) as rank, a.*, sellers.referral_code, users.uid, user_profiles.first_name, user_profiles.picture from
    (
      select 

    	  sellers.id, sellers.user_profile_id, sum(items.quantity * items.donation_amount + orders.direct_donation)

      from sellers 

      left join orders on sellers.id = orders.seller_id

      left join items on items.order_id = orders.id

      where sellers.campaign_id = " + campaign_id.to_s + " and orders.status in (1,3)

      group by sellers.id, sellers.user_profile_id

      limit 10000
      
    ) a
    inner join user_profiles on a.user_profile_id = user_profiles.id
    inner join users on user_profiles.user_id = users.id
    inner join sellers on a.id = sellers.id
    
    "
    
  end
  
end