namespace :raisy do
    desc "A weekly task to send campaign summary email to chairperson and seller"
    task :campaign_summary_weekly => :environment do
      begin
        if defined?(Rails) && (Rails.env == 'development')
          Dotenv.load
        end
      
        defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.schema_search_path = ENV['DB_SCHEMA']
        
        Cloudinary.config do |config|
          config.cloud_name = 'jli'
          config.api_key = '195568989381351'
          config.api_secret = 'wTcmdQ4UvTIjJy-2cVRykf-HiSo'
        end
        
        currTime=Time.now.utc
        
        Campaign.active.each do |campaign|
          begin
            days=(currTime-campaign.created_at)/86400
            
            if days<7 || days%7>1
              next
            end
            
            begin
              AdminMailer.camp_summary_chairperson_weekly(campaign).deliver
            rescue => eee
              puts eee.message
            end
            
            campaign.sellers.each do |seller|
              begin
                AdminMailer.camp_summary_seller_weekly(seller).deliver
              rescue => eeee
                puts eeee.message
              end
            end
          rescue => ee
            puts ee.message
          end
        end
      rescue => e
        puts e.message
      ensure
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
      end
    end
end
