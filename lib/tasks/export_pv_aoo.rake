namespace :raisy do
    desc "A daily task to export Pine Valley order file"
    task :export_pv_aoo => :environment do
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
      
        products=Product.all
        file_name="scmcdpack_raisy.xml"
        
        # Create InventoryShipOrderFile record inventory_shipment_files
        new_file=InventoryShipOrderFile.create :file_source=>"pv", :file_type=>"order", :file_name=>file_name
        
        doc = LibXML::XML::Document.new
        doc.root = LibXML::XML::Node.new('Orders')
        root = doc.root
        has_order=false
        
        Campaign.where(:is_bulk_submitted=>true, :is_bulk_ordered=>false).each do |camp|
          add_order=false
          
          node_order=LibXML::XML::Node.new("Order")
          node_order << LibXML::XML::Node.new("CustNum", "0000801")
          node_order << LibXML::XML::Node.new("OrderType", "8")
          node_order << LibXML::XML::Node.new("CustSONum", "R" + camp.id.to_s)
          node_order << LibXML::XML::Node.new("CustPONum", "R" + camp.id.to_s)
          node_order << LibXML::XML::Node.new("ShipToID", camp.organization.entertainment_customer_id)
          
          bulkshippinginfo=camp.campaign_bulkshippinginfos.first
          
          if bulkshippinginfo
            state_provinces=StateProvince.find_by_id(bulkshippinginfo.state_province_id)
            
            node_order << LibXML::XML::Node.new("ShipToName", bulkshippinginfo.ship_to_name)
            node_order << LibXML::XML::Node.new("ShipToAttn", bulkshippinginfo.ship_to_attn)
            node_order << LibXML::XML::Node.new("ShipToAddr1", bulkshippinginfo.address_line_1)
            node_order << LibXML::XML::Node.new("ShipToAddr2", bulkshippinginfo.address_line_2)
            node_order << LibXML::XML::Node.new("ShipToCity", bulkshippinginfo.city)
            
            if state_provinces
              node_order << LibXML::XML::Node.new("ShipToState", state_provinces.abbrev)
            else
              node_order << LibXML::XML::Node.new("ShipToState", "")
            end
            
            node_order << LibXML::XML::Node.new("ShipToPhone", bulkshippinginfo.phone_number)
            node_order << LibXML::XML::Node.new("ShipToZip", bulkshippinginfo.zip_code)
            node_order << LibXML::XML::Node.new("ShipToFax", "")
            node_order << LibXML::XML::Node.new("ShipToEmail", bulkshippinginfo.email_address)
            node_order << LibXML::XML::Node.new("BillToEmail2", "")
            
            if !bulkshippinginfo.delivery_datetime.nil?
              node_order << LibXML::XML::Node.new("ArrDt", bulkshippinginfo.delivery_datetime.strftime("%m/%d/%Y"))
            
              strTime=bulkshippinginfo.delivery_datetime.strftime("%H%M")
              arrTimeID="0"
            
              case strTime
              when "0900"
                arrTimeID="1"
              when "0930"
                arrTimeID="2"
              when "1000"
                arrTimeID="3"
              when "1030"
                arrTimeID="4"
              when "1100"
                arrTimeID="5"
              when "1130"
                arrTimeID="6"
              when "1200"
                arrTimeID="7"
              when "1230"
                arrTimeID="8"
              when "1300"
                arrTimeID="9"
              when "1330"
                arrTimeID="10"
              when "1400"
                arrTimeID="11"
              else
                arrTimeID="0"
              end
            
              node_order << LibXML::XML::Node.new("ArrTimeID", arrTimeID)
            else
              node_order << LibXML::XML::Node.new("ArrDt", "")
              node_order << LibXML::XML::Node.new("ArrTimeID", "0")
            end
          else
            node_order << LibXML::XML::Node.new("ShipToName", "")
            node_order << LibXML::XML::Node.new("ShipToAttn", "")
            node_order << LibXML::XML::Node.new("ShipToAddr1", "")
            node_order << LibXML::XML::Node.new("ShipToAddr2", "")
            node_order << LibXML::XML::Node.new("ShipToCity", "")
            node_order << LibXML::XML::Node.new("ShipToState", "")
            node_order << LibXML::XML::Node.new("ShipToPhone", "")
            node_order << LibXML::XML::Node.new("ShipToZip", "")
            node_order << LibXML::XML::Node.new("ShipToFax", "")
            node_order << LibXML::XML::Node.new("ShipToEmail", "")
            node_order << LibXML::XML::Node.new("BillToEmail2", "")
            node_order << LibXML::XML::Node.new("ArrDt", "")
            node_order << LibXML::XML::Node.new("ArrTimeID", "0")
          end
          
          node_order << LibXML::XML::Node.new("SoNotes", "")
          node_order << LibXML::XML::Node.new("AncillaryItems")
          
          leaders=[]  # Entries of Leader nodes, {name, node, needed}
          sellers=[]  # Array of Seller nodes, {id, sid, node}
          leader_id=0
          seller_id=0
          rec_id=0
          
          node_order << detail_pps=LibXML::XML::Node.new("DetailPPS")
          
          # DetailPPS
          #  Leader
          #   LeaderID
          #   LeaderName
          #   Seller
          #    SellerID
          #    SellerName
          #    Item
          #     ItemNum
          #     Qty
          #     RecID
          
          item_nodes=[] # Array of item nodes, {sku, qty, rec_id, sid, seller}
          
          leader = LibXML::XML::Node.new("Leader")
          leader << LibXML::XML::Node.new("LeaderID", "1")
          leader << LibXML::XML::Node.new("LeaderName", "")
          
          leader_entry={:name => "", :node => leader, :needed => false}
          leaders << leader_entry
          
          camp.orders.completed.joins("LEFT JOIN sellers ON orders.seller_id = sellers.id").joins("LEFT JOIN user_profiles ON sellers.user_profile_id = user_profiles.id").order('user_profiles.last_name, user_profiles.first_name').each do |order|
            # Find or create the Leader node
            # name=order.seller_id.nil? ? "" : (order.seller.homeroom || "")
#
#             idx=leaders.index {|entry| entry[:name]==name }
#
#             if idx
#               leader_entry=leaders[idx]
#               leader=leader_entry[:node]
#             else
#               leader_id+=1
#
#               leader=LibXML::XML::Node.new("Leader")
#               leader << LibXML::XML::Node.new("LeaderID", leader_id.to_s)
#               leader << LibXML::XML::Node.new("LeaderName", name)
#
#               leader_entry={:name => name, :node => leader, :needed => false}
#
#               leaders << leader_entry
#             end
            
            # Find or create the Seller node
            sid = order.seller_id.nil? ? 0 : order.seller_id
            idx = sellers.index {|seller| seller[:sid]==sid }
            
            if idx
              seller=sellers[idx][:node]
            else
              seller_id += 1
              
              name=order.seller_id.nil? ? "" : (order.seller.user_profile.fullname || "")
              
              seller=LibXML::XML::Node.new("Seller")
              seller << LibXML::XML::Node.new("SellerID", seller_id.to_s)
              seller << LibXML::XML::Node.new("SellerName", name)
              
              sellers << {:id => seller_id, :sid => sid, :node => seller}
              leader << seller
            end
            
            order.items.each do |item|
              if item.delivery_method==3 && item.delivery_status==1
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
                  idx=item_nodes.index {|entry| entry[:sku]==sku && entry[:sid]==sid }
                  
                  if idx
                    item_nodes[idx][:qty]=item_nodes[idx][:qty]+item.quantity
                    
                    item.rec_id=item_nodes[idx][:rec_id].to_s
                  else
                    rec_id+=1
                    
                    item_nodes << {:sku => sku, :qty => item.quantity, :rec_id => rec_id, 
                                    :sid => sid, :seller => seller}
                    
                    item.rec_id=rec_id.to_s
                  end
                  
                  item.delivery_status=3
                  item.delivery_updated_at=DateTime.now
                  item.save
                  
                  add_order=true  
                  has_order=true
                  leader_entry[:needed]=true # This Leader node should be added to DetailPPS
                end
              end
            end
          end
          
          # Add item nodes to seller
          item_nodes.each do |node|
            item_node=LibXML::XML::Node.new("Item")
            item_node << LibXML::XML::Node.new("ItemNum", node[:sku])
            item_node << LibXML::XML::Node.new("Qty", node[:qty].to_s)
            item_node << LibXML::XML::Node.new("RecID", node[:rec_id].to_s)
            
            node[:seller] << item_node
          end
          
          # Add Order and Leader nodes to root if they have any items
          if add_order
            leaders.each do |entry|
              if entry[:needed]
                detail_pps << entry[:node]
                
                entry[:needed]=false
              end
            end
            
            root << node_order
          end
          
          camp.is_bulk_ordered=true
          camp.bulk_ordered_at=DateTime.now
          camp.save
        end
        
        if !has_order
          puts "no pv aoo"
        else
          file_path="./tmp/" + file_name
        
          doc.save(file_path, :indent => true, :encoding => LibXML::XML::Encoding::UTF_8)
          
          use_sftp=(ENV['PV_USE_SFTP']=="1")
          ftp_uploaded=false
          
          if use_sftp
            begin
              Net::SFTP.start(ENV['PV_SFTP_HOST'], ENV['PV_SFTP_USER'], password: ENV['PV_SFTP_PASSWORD'], port: ENV['PV_SFTP_PORT']) do |sftp|
                sftp.upload!(file_path, ENV['PV_SFTP_AOO_DIR'] + file_name)
              end
              
              ftp_uploaded=true
            rescue => ee
              puts ee.message
            ensure
            end
          else
            begin
              ftp = Net::FTP.new
              ftp.passive = true
              ftp.connect ENV['PV_SFTP_HOST'], ENV['PV_SFTP_PORT']
              ftp.login ENV['PV_SFTP_USER'], ENV['PV_SFTP_PASSWORD']
              
              ftp.putbinaryfile(file_path, ENV['PV_SFTP_AOO_DIR'] + file_name)
              ftp.close
              
              ftp_uploaded=true
            rescue => eeee
              puts eeee.message
            ensure
            end
          end
          
          begin
            # Save the file to cloud
            cloud_hash=Cloudinary::Uploader.upload(file_path, :public_id=>Time.now.strftime("%s") + ".xml", :resource_type=>:raw)
          rescue => eee
            puts eee.message
          ensure
          end

          if cloud_hash
            new_file.cloud_url=cloud_hash["secure_url"]
            new_file.cloud_public_id=cloud_hash["public_id"]
          end

          if ftp_uploaded
            new_file.file_status=1
            new_file.save
          end
        end
      rescue => e
        puts e.message
      ensure
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
      end
    end
end
