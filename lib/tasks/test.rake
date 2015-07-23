namespace :eleven do

    # To run this rake task, make sure the necessary SFTP credentials are in .env
    # foreman run rake membership_activation:import_access_code

    desc "Update stripe subscription quantity"
    task :test => :environment do
        
        require "mail"
        
        defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.schema_search_path = ENV['DB_SCHEMA']
        
        if defined?(Rails) && (Rails.env == 'development')
          Rails.logger = Logger.new(STDOUT)
        end
        
        aa = 'sandboxf6264257eeaf4129a4fb02ac4e7e987e.mailgun.org'
        bb = 'postmaster@sandboxf6264257eeaf4129a4fb02ac4e7e987e.mailgun.org'
        cc = '7q7vmclgby93'
        
        # Send file to vendor via email
        Mail.defaults do
          delivery_method :smtp, {
            :address=> "smtp.mailgun.org",
            :port=> 587,
            :domain=> aa,
            :user_name=> bb,
            :password=> cc,
            :authentication=> 'plain' }
        end

        Mail.deliver do
          from     'admin@11hao.com'
          to       'rwen@dowelltech.cn'
          subject  '11号公益圈订单'
          body     "无订单"
        end
        
    end

end
