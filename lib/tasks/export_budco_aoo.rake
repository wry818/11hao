namespace :raisy do
    desc "A daily task to export Budco order file"
    task :export_budco_aoo => :environment do
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
      
        products=Product.all
        prev_file=InventoryShipOrderFile.where(:file_source=>"budco", :file_type=>"order", :file_status=>1).last
        file_name="BSEPIORDERB" + Time.now.strftime("%m%d%Y%H%M") + ".txt"
        
        # Create InventoryShipOrderFile record inventory_shipment_files
        new_file=InventoryShipOrderFile.create :file_source=>"budco", :file_type=>"order", :file_name=>file_name
        new_file_id=new_file.id.to_s.rjust(6, "0")
        prev_file_id="000000"
        
        if prev_file
           prev_file_id=prev_file.id.to_s.rjust(6, "0")
        end
        
        line=""
        total_no=0
        trans_id="000000"
        promo_code="".ljust(15, " ")
        epi_code="000000"
        company="".ljust(50, " ")
        msg="".ljust(150, " ")
        po_nbr="".ljust(25, " ")
        isbn_nbr="".ljust(20, " ")
        label_ind=" "
        order_src="".ljust(5, " ")
        cost_center="0000"
        invoice_nbr="".ljust(15, " ")
        rush_ind="0"  # 0=standard; 1=ovenight; 2=second day; 3=express
        ship_price="000.00"
        retail_price="000.00"
        project="63183"
        pick_batch_id="".ljust(10, "0")
        pick_line_no="".ljust(5, "0")
        sched_date=Time.now.strftime("%m/%d/%Y")
        rep_name="EPI ORDER".ljust(50, " ")
        file_type="BS"
        additional_field="".ljust(1216," ")
        
        can_continue=true
        
        Order.completed.each do |order|
          if !can_continue
            break
          end
          
          item_no=0
          
          # The prefix R for raisy
          order_id= "R" + order.id.to_s.rjust(8, "0")
          
          order.items.each do |item|
            if !can_continue || item_no>=999
              break
            end
            
            if item.delivery_method==2 && item.delivery_status==1
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
                    if p.id==item.product_id && p.vendor=="Budco"
                      sku=property.sku.strip.ljust(10, " ")[0,10]
                    end
                  end
                end
              else
                products.each do |p|
                  if p.id==item.product_id && !p.sku.nil? && p.vendor=="Budco"
                    sku=p.sku.strip.ljust(10, " ")[0,10]
                  end
                end
              end
              
              if sku!=""
                if total_no>=99999
                  can_continue=false
                  
                  break
                end
                
                total_no+=1
                item_no+=1
                item_nbr=item_no.to_s.rjust(3, "0")
                cust_id=order.id.to_s.rjust(10, "0")
                cust_name=order.fullname || ""
                cust_name=cust_name.ljust(51, " ")[0,51]
                reci_name=order.address_fullname || ""
                reci_name=reci_name.ljust(51, " ")[0,51]
                addr_line1=order.address_line_one || ""
                addr_line1=addr_line1.ljust(50, " ")[0,50]
                addr_line2=order.address_line_two || ""
                addr_line2=addr_line2.ljust(50, " ")[0,50]
                city=order.address_city || ""
                city=city.ljust(35, " ")[0,35]
                state=order.address_state || ""
                state=state.ljust(2, " ")[0,2]
                zip=order.address_postal_code || ""
                zip=zip.ljust(25, " ")[0,25]
                country=order.address_country + ""
                country=country.ljust(25, " ")[0,25]
                qty=item.quantity.to_s.rjust(6, "0")[0,6]
                phone=order.phone_number || ""
                phone=phone.rjust(15, "0")[0,15]
                unit_price="%.2f" % (item.unit_price.to_f/100)
                unit_price=unit_price.rjust(6, "0")[0,6]
                
                line+=new_file_id + prev_file_id + trans_id + promo_code + sku
                line+=epi_code + cust_id + order_id + item_nbr + reci_name + cust_name
                line+=company + addr_line1 + addr_line2 + city + state + zip + country
                line+=rush_ind + msg + qty + po_nbr + isbn_nbr + unit_price + ship_price
                line+=label_ind + order_src + cost_center + invoice_nbr + retail_price
                line+=phone + project + pick_batch_id + pick_line_no + sched_date + phone
                line+=rep_name + file_type + additional_field + "\n"
                
                item.delivery_status=3
                item.delivery_updated_at=DateTime.now
                item.rec_id=item_nbr
                item.save
              end
            end
          end
        end
        
        if total_no==0
          puts "no budco aoo"
        else
          line+=new_file_id + prev_file_id + "TRAILER" + total_no.to_s.rjust(5, " ")
          file_path="./tmp/" + file_name
        
          File.open(file_path, "w") do |f|
            f.write line
          end
        
          begin
            Net::SFTP.start(ENV['BUDCO_SFTP_HOST'], ENV['BUDCO_SFTP_USER'], password: ENV['BUDCO_SFTP_PASSWORD'], port: ENV['BUDCO_SFTP_PORT']) do |sftp|
              sftp.upload!(file_path, ENV['BUDCO_SFTP_AOO_DIR'] + file_name)
            
              begin
                # Save the file to cloud
                cloud_hash=Cloudinary::Uploader.upload(file_path, :public_id=>Time.now.strftime("%s") + ".txt", :resource_type=>:raw)
              rescue => eee
                puts eee.message
              ensure
              end
      
              if cloud_hash
                new_file.cloud_url=cloud_hash["secure_url"]
                new_file.cloud_public_id=cloud_hash["public_id"]
              end
        
              new_file.file_status=1
              new_file.save
            end
          rescue => ee
            puts ee.message
          ensure
          end
        end
      rescue => e
        puts e.message
      ensure
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
      end
    end
end
