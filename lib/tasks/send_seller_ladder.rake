namespace :eleven do

    # To run this rake task, make sure the necessary SFTP credentials are in .env
    # foreman run rake membership_activation:import_access_code

    desc "Send Seller Ladder"
    
    task :send_seller_ladder => :environment do
       
        defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.schema_search_path = ENV['DB_SCHEMA']
        
        Rails.logger = Logger.new(STDOUT)
        
        campaigns = Campaign.active.order(:id=>:desc)

        campaigns.each do |campaign|

          Rails.logger.info "Send seller ladder for campaign_id:" + campaign.id.to_s + " title: " + campaign.title + " begin"
          # Rails.logger.info Rails.env
          $wechat_client ||= WeixinAuthorize::Client.new(ENV["WEIXIN_APPID"], ENV["WEIXIN_APP_SECRET"])
          
          query = QueryHelper.get_seller_ladder(campaign.id)
          
          seller_ladder_result = ActiveRecord::Base.connection.execute(query)
      
          seller_ladder_result.each do |row|
            
            Rails.logger.info row["uid"]
            if row["uid"] && row["uid"].length > 0
              
              url = ""
              if defined?(Rails) && (Rails.env == 'development')
                url = "http://www.11haoonline.com"
              else
                url = "http://test.11haoonline.com"
              end
            
              Rails.logger.info url
            
              articles = [
                {
                  title: "您在" + campaign.title + "的排名",
                  description: "您当前的排名：" + "第" + row["rank"] + "名。\n点击查看其他志愿者的排名。",
                  url: url
                }
              ]

              $wechat_client.send_news_custom(row["uid"], articles)
              
            end
        
          end
          
          Rails.logger.info "Send seller ladder for campaign_id:" + campaign.id.to_s + " title: " + campaign.title + " end"
          
        end
        
    end

end
