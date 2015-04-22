namespace :raisy do
    desc "A daily task to import Budco ship file"
    task :import_budco_aos => :environment do
      begin
        if defined?(Rails) && (Rails.env == 'development')
          Dotenv.load
          
          Cloudinary.config do |config|
            config.cloud_name = 'jli'
            config.api_key = '195568989381351'
            config.api_secret = 'wTcmdQ4UvTIjJy-2cVRykf-HiSo'
          end
        end
      
        defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.schema_search_path = ENV['DB_SCHEMA']
        
        #1395;1
        
        # order=Order.find_by_id(1395)
        #
        # begin
        #   UserMailer.consumer_shipment_confirmation(order, order.campaign).deliver
        # rescue => eeee
        #   puts eeee.message
        # end
        #
        # puts "done"
        #
        # exit
        
        existing_files=InventoryShipOrderFile.where(:file_source=>"budco", :file_type=>"ship", :file_status=>1)
        products=Product.all
        
        # Check Budco AOS files
        Net::SFTP.start(ENV['BUDCO_SFTP_HOST'], ENV['BUDCO_SFTP_USER'], password: ENV['BUDCO_SFTP_PASSWORD'], port: ENV['BUDCO_SFTP_PORT']) do |sftp|
          sftp.dir.glob(ENV['BUDCO_SFTP_AOS_DIR'], "*.txt") do |entry|
            begin
              # Check to see if the file has been imported
              if entry.file?
                is_new_file=true
              
                existing_files.each do |file|
                  if file.file_name == entry.name
                    is_new_file=false
                    break
                  end
                end
              
                if is_new_file
                  puts entry.name
                
                  # Download the file
                  file_name="./tmp/" + entry.name
                  sftp.download!(ENV['BUDCO_SFTP_AOS_DIR'] + entry.name, file_name)
                  
                  begin
                    # Save the file to cloud
                    cloud_hash=Cloudinary::Uploader.upload(file_name, :public_id=>Time.now.strftime("%s") + ".txt", :resource_type=>:raw)
                  rescue => eee
                    puts eee.message
                  ensure
                  end
                                    
                  # Create InventoryShipOrderFile record
                  new_file=InventoryShipOrderFile.create :file_source=>"budco", :file_type=>"ship", :file_name=>entry.name, 
                    :cloud_url => (cloud_hash ? cloud_hash["secure_url"] : ""), 
                    :cloud_public_id => (cloud_hash ? cloud_hash["public_id"] : "")
                    
                  order_ids=[]
                  
                  # Update item delivery status
                  File.open(file_name, "r").each do |line|
                    order_id=line[18, 9]
                    sku=line[147, 10]
                    rec_id=line[157, 3]
                    track_num=line[117, 30]
                    
                    # order_id sent from raisy has a prefix "R"
                    if !order_id.nil? && !sku.nil? && !rec_id.nil? && !track_num.nil? && order_id[0]=="R"
                      order_id=order_id[1..-1].strip
                      track_num=track_num.strip
                      sku=sku.strip
                      items=Item.where(:order_id=>order_id.to_i, :rec_id=>rec_id, :delivery_status=>3, :delivery_method=>2)
                      
                      items.each do |item|
                        option=item.options.first
                        check_property=false
              
                        if option
                          property=option.option_group_property
                
                          if property
                            check_property=true
                          end
                        end
                        
                        if check_property
                          if !property.sku.nil? && property.sku!="" && property.sku.strip == sku
                            products.each do |p|
                              if p.vendor=="Budco" && item.product_id==p.id
                                item.delivery_status=2
                                item.delivery_updated_at=DateTime.now
                                item.tracking_number=track_num
                                item.save
                                
                                order_ids<<order_id.to_i
                              end
                            end
                          end
                        else
                          products.each do |p|
                            if !p.sku.nil? && p.sku!="" && p.sku.strip == sku && p.vendor=="Budco" && item.product_id==p.id
                              item.delivery_status=2
                              item.delivery_updated_at=DateTime.now
                              item.tracking_number=track_num
                              item.save
                              
                              order_ids<<order_id.to_i
                            end
                          end
                        end
                      end
                    end
                  end
                  
                  new_file.file_status=1
                  new_file.save
                  
                  order_ids=order_ids.uniq
                  
                  order_ids.each do |order_id|
                    # Check orders that need to send shipment confirmation email
                    if Item.where(:order_id=>order_id, :delivery_method=>2).where.not(:delivery_status=>2).count==0
                      order=Order.find_by_id(order_id)
                      
                      begin
                        UserMailer.consumer_shipment_confirmation(order, order.campaign).deliver
                      rescue => eeee
                        puts eeee.message
                      end
                    end
                  end
                end
              end
            rescue => ee
              puts ee.message
            ensure
              # Ensure that each file can be processed
            end
          end
        end
      rescue => e
        puts e.message
      ensure
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
      end
    end
end
