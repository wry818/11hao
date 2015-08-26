namespace :eleven do

    # To run this rake task, make sure the necessary SFTP credentials are in .env
    # foreman run rake membership_activation:import_access_code

    desc "Send Seller Ladder"
    
    task :send_seller_ladder => :environment do
       
        defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.schema_search_path = ENV['DB_SCHEMA']
        
        Rails.logger = Logger.new(STDOUT)
        
        campaigns = Campaign.active.order(:id=>:desc)
        
        yesterday = Time.now - 300.day
        
        campaigns.each do |campaign|
          
          orders = Order.completed.where(["orders.campaign_id= ? and orders.created_at >= ?", campaign.id, yesterday])
          
          if orders && orders.count > 0
            
            Rails.logger.info "Send seller ladder for campaign_id:" + campaign.id.to_s + " title: " + campaign.title + " begin"
            # Rails.logger.info Rails.env
            $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
          
            query = QueryHelper.get_seller_ladder(campaign.id, campaign.campaign_mode)

            seller_ladder_result = ActiveRecord::Base.connection.execute(query)

            seller_ladder_result.each do |row|

              # Rails.logger.info row["uid"]
              
              if row["uid"] && row["uid"].length > 0

                url = ""
                if defined?(Rails) && (Rails.env == 'development')
                  url = "http://www.11haoonline.com"
                else
                  url = "http://test.11haoonline.com"
                end

                url += "/seller/" + row["referral_code"] + "/seller_ladder"

                # Rails.logger.info url
                
                title = ""
                
                if campaign.campaign_mode == Campaign::Fundraising
                  
                  seller_orders = orders.where(:seller_id => row["id"].to_i)
                  
                  if seller_orders && seller_orders.count > 0
                    
                    seller_total_raised = (seller_orders.joins(:items).sum('items.quantity * items.donation_amount') + seller_orders.sum('direct_donation') )/ 100.0
                    # seller_total_raised = QueryHelper.short_price(seller_total_raised)
                    
                    title = "您今天为" + campaign.title + "筹得募款" + seller_total_raised.to_s + "元！"
                    
                  else
                    
                    title = campaign.title + "活动筹款义卖排名"
                      
                  end
      
                else
      
                  seller_orders = orders.where(:seller_id => row["id"].to_i)
                  
                  if seller_orders && seller_orders.count > 0
                    
                    title = "您今天为" + campaign.title + "募集了" + seller_orders.count.to_s + "颗爱心！"
                    
                  else
                    
                    title = campaign.title + "活动爱心募集排名"
                      
                  end
      
                end
                
                Rails.logger.info title
                  
                articles = [
                  {
                    title: title,
                    description: "您当前的排名：" + "第" + row["rank"] + "名。\n点击查看其他小伙伴的排名。",
                    url: url
                  }
                ]

                $wechat_client.send_news_custom(row["uid"], articles)

              end

            end
          
            Rails.logger.info "Send seller ladder for campaign_id:" + campaign.id.to_s + " title: " + campaign.title + " end"
          
          else
            
            Rails.logger.info "No order for this campaign last 24 hours campaign_id:" + campaign.id.to_s + " title: " + campaign.title
            
          end
          
        end
        
    end

end
