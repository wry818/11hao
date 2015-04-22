namespace :raisy do
    desc "A daily task to import Budco inventory file"
    task :import_budco_aoi => :environment do
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
        
        existing_files=InventoryShipOrderFile.where(:file_source=>"budco", :file_type=>"inventory", :file_status=>1)
        products=Product.all
        
        # Check Budco AOI files
        Net::SFTP.start(ENV['BUDCO_SFTP_HOST'], ENV['BUDCO_SFTP_USER'], password: ENV['BUDCO_SFTP_PASSWORD'], port: ENV['BUDCO_SFTP_PORT']) do |sftp|
          sftp.dir.glob(ENV['BUDCO_SFTP_AOI_DIR'], "*.txt") do |entry|
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
                  sftp.download!(ENV['BUDCO_SFTP_AOI_DIR'] + entry.name, file_name)
                
                  begin
                    # Save the file to cloud
                    cloud_hash=Cloudinary::Uploader.upload(file_name, :public_id=>Time.now.strftime("%s") + ".txt", :resource_type=>:raw)
                  rescue => eee
                    puts eee.message
                  ensure
                  end
                  
                  # Create InventoryShipOrderFile record
                  new_file=InventoryShipOrderFile.create :file_source=>"budco", :file_type=>"inventory", :file_name=>entry.name, 
                    :cloud_url => (cloud_hash ? cloud_hash["secure_url"] : ""), 
                    :cloud_public_id => (cloud_hash ? cloud_hash["public_id"] : "")
                  
                  # Update product inventory
                  File.open(file_name, "r").each do |line|
                    sku=line[18, 10]
                    qty=line[28, 8]
          
                    if !sku.nil? && !qty.nil?
                      products.each do |p|
                        if !p.sku.nil? && p.sku!="" && p.sku.strip == sku.strip && p.vendor=="Budco"
                          p.qty_counter = 0
                          p.qty_available = qty.to_i
                          p.inventory_last_update_time = DateTime.now
                          p.save
                        end
                        
                        if p.vendor=="Budco"
                          # Update option group property if any
                          p.option_groups.active.each do |group|
                            group.option_group_properties.active.each do |prop|
                              if !prop.sku.nil? && prop.sku!="" && prop.sku.strip == sku.strip
                                prop.qty_counter = 0
                                prop.qty_available = qty.to_i
                                prop.inventory_last_update_time = DateTime.now
                                prop.save
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                  
                  new_file.file_status=1
                  new_file.save
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
