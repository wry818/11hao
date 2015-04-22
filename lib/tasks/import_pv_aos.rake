namespace :raisy do
    desc "A daily task to import Pine Valley ship file"
    task :import_pv_aos => :environment do
      require 'libxml'
      require 'net/ftp'
      
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
        
        #1398;180
        
        # campaign=Campaign.find_by_id(180)
        #
        # begin
        #   UserMailer.chairperson_shipment_confirmation(campaign).deliver
        # rescue => eeee
        #   puts eeee.message
        # end
        #
        # puts "done"
        #
        # exit
        
        existing_files=InventoryShipOrderFile.where(:file_source=>"pv", :file_type=>"ship", :file_status=>1)
        products=Product.all
        
        use_sftp=(ENV['PV_USE_SFTP']=="1")
        new_files=[]
        
        # Check Pine Valley AOS files
        if use_sftp
          Net::SFTP.start(ENV['PV_SFTP_HOST'], ENV['PV_SFTP_USER'], password: ENV['PV_SFTP_PASSWORD'], port: ENV['PV_SFTP_PORT']) do |sftp|
            sftp.dir.glob(ENV['PV_SFTP_AOS_DIR'], "*.xml") do |entry|
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
                
                  is_new_file=true  # PV AOS has fixed file name? No timestamp or sth else?
              
                  if is_new_file
                    puts entry.name
                
                    # Download the file
                    file_name="./tmp/" + entry.name
                    sftp.download!(ENV['PV_SFTP_AOS_DIR'] + entry.name, file_name)
                  
                    begin
                      # Save the file to cloud
                      cloud_hash=Cloudinary::Uploader.upload(file_name, :public_id=>Time.now.strftime("%s") + ".xml", :resource_type=>:raw)
                    rescue => eee
                      puts eee.message
                    ensure
                    end
                  
                    # Create InventoryShipOrderFile record
                    new_file=InventoryShipOrderFile.create :file_source=>"pv", :file_type=>"ship", :file_name=>entry.name, 
                      :cloud_url => (cloud_hash ? cloud_hash["secure_url"] : ""), 
                      :cloud_public_id => (cloud_hash ? cloud_hash["public_id"] : "")
                      
                    new_files << new_file
                  end
                end
              rescue => ee
                puts ee.message
              ensure
                # Ensure that each file can be processed
              end
            end
          end
        else
          # Download files thru FTP
          ftp = Net::FTP.new
          ftp.passive = true
          ftp.connect ENV['PV_SFTP_HOST'], ENV['PV_SFTP_PORT']
          ftp.login ENV['PV_SFTP_USER'], ENV['PV_SFTP_PASSWORD']
          
          file_names=ftp.nlst(ENV['PV_SFTP_AOS_DIR'] + "*.xml")
          
          file_names.each do |name|
            puts name
            
            file_name="./tmp/" + name
            ftp.getbinaryfile(ENV['PV_SFTP_AOS_DIR'] + name, file_name)
            
            begin
              # Save the file to cloud
              cloud_hash=Cloudinary::Uploader.upload(file_name, :public_id=>Time.now.strftime("%s") + ".xml", :resource_type=>:raw)
            rescue => eee
              puts eee.message
            ensure
            end
          
            # Create InventoryShipOrderFile record
            new_file=InventoryShipOrderFile.create :file_source=>"pv", :file_type=>"ship", :file_name=>name, 
              :cloud_url => (cloud_hash ? cloud_hash["secure_url"] : ""), 
              :cloud_public_id => (cloud_hash ? cloud_hash["public_id"] : "")
              
            new_files << new_file
          end
    
          ftp.close
        end
        
        new_files.each do |new_file|
          # Parse xml and find matched campaigns
          parser = LibXML::XML::Parser.file("./tmp/" + new_file.file_name)
          doc = parser.parse
          node_orders=doc.find_first("//Orders")

          node_orders.find("Order").each do |node_order|
            cust_so_num=node_order.find_first("CustSONum")
  
            if !cust_so_num
              next
            end
            
            campaign_id=cust_so_num.content || ""
            
            puts campaign_id
            
            if campaign_id=="" || campaign_id[0]!="R"
              next
            end
            
            campaign_id=campaign_id[1..-1].strip
  
            campaign=Campaign.find_by_id(campaign_id)
  
            if !campaign
              next
            end
  
            detail_pps=node_order.find_first("DetailPPS")

            if !detail_pps
              next
            end
            
            track_num=""
            track_num_node=node_order.find_first("TrackNum")
            
            if track_num_node
              track_num=track_num_node.content || ""
              track_num=track_num.strip
            end
  
            node_items=detail_pps.find("Leader/Seller/Item")
            
            is_item_shipped=false
  
            campaign.orders.completed.each do |order|
              order.items.where(:delivery_status=>3, :delivery_method=>3).each do |item|
                rec_id=item.rec_id              
                sku=""
                option=item.options.first
                check_property=false
      
                if option
                  property=option.option_group_property
        
                  if property
                    check_property=true
                  end
                end
                
                if check_property
                  if !property.sku.nil?
                    products.each do |p|
                      if p.id==item.product_id && p.vendor=="PV"
                        sku=property.sku.strip
                      end
                    end
                  end
                else
                  products.each do |p|
                    if p.id==item.product_id && !p.sku.nil? && p.vendor=="PV"
                      sku=p.sku.strip
                    end
                  end
                end
                
                if sku!=""
                  node_items.each do |node|
                    node_rec_id=node.find_first("RecID")
                    node_sku=node.find_first("ItemNum")
          
                    if !node_rec_id || !node_sku
                      next
                    end
          
                    if rec_id!=node_rec_id.content.strip || sku!=node_sku.content.strip
                      next
                    end
                    
                    # Update item delivery status and tracking number
                    
                    item.delivery_status=2
                    item.delivery_updated_at=DateTime.now
                    item.tracking_number=track_num
                    item.save
                    
                    is_item_shipped=true
                  end
                end
              end
            end
            
            if is_item_shipped
              # Send shipment confirmation email to chairperson
              begin
                UserMailer.chairperson_shipment_confirmation(campaign).deliver
              rescue => eeee
                puts eeee.message
              end
            end
          end
          
          new_file.file_status=1
          new_file.save
        end
      rescue => e
        puts e.message
      ensure
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
      end
    end
end
