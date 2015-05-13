namespace :eleven do
    desc "A daily task to export vendor order file"
    task :export_vendor_aoo => :environment do
      require "mail"
      
      begin
        # ActiveRecord::Base.logger = Logger.new(STDOUT)
        
        vendors=Vendor.active.all
        
        vendors.each do |vendor|
          products=Product.where(:fulfillment_method=>2, :vendor_id=>vendor.id).all
          prod_ids=products.collect(&:id)
         
          items=Item.joins("inner join orders on items.order_id=orders.id").where(
            "orders.status in (1,3) and items.delivery_method=2 and 
            items.delivery_status=1 and items.product_id in (:prod_ids)", prod_ids: prod_ids).readonly(false).all
            
          orders=Order.where(:id=>items.collect(&:order_id).uniq).all

          has_item=false
          lines="订单日期|订单号|订单详情号|数量|货品名称|收货人姓名|收货地址|邮编|收货电话"
          
          items.each do |item|
            order=orders.select{|o| o.id==item.order_id}.first
            
            address=(order.address_country || "") + " " + (order.address_state || "") + " " + (order.address_city || "") + " "
            address+=(order.address_line_one || "") + " " + (order.address_line_two || "")
            
            line=item.created_at.strftime("%Y-%m-%d") + "|" + item.order_id.to_s + "|" + item.id.to_s + "|"
            line+=item.quantity.to_s + "|" + products.select{|p| p.id==item.product_id}.first.name + "|"
            line+=(order.address_fullname || "") + "|" + address + "|" + (order.address_postal_code || "") + "|" + (order.phone_number || "")
            
            lines+="\r\n" + line
            
            item.delivery_status=3
            item.delivery_updated_at=DateTime.now
            item.save
            
            has_item=true
          end
          
          if has_item
            # Send file to vendor via email
            
            file_path="./tmp/" + Time.now.strftime("%Y%m%d%H%M") + ".txt"
            
            File.open(file_path, "w") do |f|
              f.write lines
            end
            
            Mail.defaults do
              delivery_method :smtp, { 
                :address=> "smtp.mailgun.org",
                :port=> 587,
                :domain=> 'sandbox878e3120a7e94827a62bffa19d89f1b1.mailgun.org',
                :user_name=> 'postmaster@sandbox878e3120a7e94827a62bffa19d89f1b1.mailgun.org',
                :password=> 'a5dc51db8a5eeea81835fd7d6a18c72f',
                :authentication=> 'plain' }
            end
            
            Mail.deliver do
              from     'admin@11hao.com'
              to       vendor.email
              subject  '11号公益圈订单'
              body     "11号公益圈订单 - " + Time.now.strftime("%Y%m%d%H%M") + ".txt"
              add_file file_path
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
