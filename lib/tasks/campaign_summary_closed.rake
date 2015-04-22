namespace :raisy do
    desc "A task to send campaign summary/bulk order email to chairperson"
    task :campaign_summary_closed => :environment do
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
        
        Campaign.ended.where("is_summary_emailed=false and summary_email_retry_times<3").each do |campaign|
          begin
            campaign.summary_email_retry_times=campaign.summary_email_retry_times+1
            campaign.save
            
            AdminMailer.campaign_summary_closed(campaign).deliver
            
            campaign.is_summary_emailed=true
            campaign.summary_emailed_at=DateTime.now
            campaign.save
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