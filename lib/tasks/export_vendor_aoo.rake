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
            items.delivery_status=1 and items.product_id in (:prod_ids)", prod_ids: prod_ids)
            .order(:order_id).readonly(false).all
            
          orders=Order.where(:id=>items.collect(&:order_id).uniq).all

          has_item=false
          file_name=Time.now.strftime("%Y%m%d%H%M") + ".xlsx"
          file_path="./tmp/" + file_name
          
          Axlsx::Package.new do |p|
            p.workbook.add_worksheet(:name => "订单") do |sheet|
              sheet.add_row ["订单日期", "订单号", "订单详情号", "货品名称", "数量", "收货人姓名",
                "省份", "城市", "收货地址", "邮编", "联系电话"]
                
                items.each do |item|
                  order=orders.select{|o| o.id==item.order_id}.first
                  
                  sheet.add_row [item.created_at.strftime("%Y-%m-%d"),
                    item.order_id.to_s, item.id.to_s,
                    products.select{|p| p.id==item.product_id}.first.name,
                    item.quantity.to_s,
                    (order.address_fullname || ""),
                    (order.address_state || ""),
                    (order.address_city || ""),
                    (order.address_line_one || ""),
                    (order.address_postal_code || ""),
                    (order.phone_number || "")]
            
                  item.delivery_status=3
                  item.delivery_updated_at=DateTime.now
                  item.save
            
                  has_item=true
                end
            end
            
            p.serialize(file_path)
          end
          
          # Send file to vendor via email
          Mail.defaults do
            delivery_method :smtp, { 
              :address=> "smtp.mailgun.org",
              :port=> 587,
              :domain=> ENV['MAILGUN_DOMAIN'],
              :user_name=> ENV['MAILGUN_USERNAME'],
              :password=> ENV['MAILGUN_PASSWORD'],
              :authentication=> 'plain' }
          end
          
          if has_item
            Mail.deliver do
              from     'admin@11hao.com'
              to       vendor.email
              subject  '11号公益圈订单'
              body     "11号公益圈订单 - " + file_name
              add_file file_path
            end
          else
            # Mail.deliver do
#               from     'admin@11hao.com'
#               to       vendor.email
#               subject  '11号公益圈订单'
#               body     "无订单"
#             end
          end
        end
      rescue => e
        puts e.message
      ensure
        defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
      end
    end
end
