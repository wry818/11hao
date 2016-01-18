class Item < ActiveRecord::Base
    belongs_to :order
    belongs_to :product
    has_many :options
    has_many :registration_codes
    
    # delivery_status: 1- Waiting for delivery, 2- Delivered, 3-Delivering

    def delivery_status_text
      case self.delivery_status
        when 1
            'Waiting for delivery'
        when 2
            'Delivered'
        when 3
            'Delivering'
        else
            ''
      end
    end

    def courier_numbers
      self.courier_number.split(/[,，]/)
    end

    def delivery_method_text
      case self.delivery_method
        when 1
            '通过邮件发送'
        when 2
            '快递免运费'
        when 3
            '快递免运费'
        else
            ''
      end
    end
    
    def delivery_method_icon
      case self.delivery_method
        when 1
            'mail_delivery.png'
        when 2
            'free_shipping.png'
        when 3
            'bulk_shipping.png'
        else
            ''
      end
    end

    def total_price
        (self.base_amount + self.donation_amount) * self.quantity
    end
    
    def total_origin_price
        self.is_discount ? (self.origin_base_amount + self.origin_donation_amount) * self.quantity : (self.base_amount + self.donation_amount) * self.quantity
    end
    
    def unit_price
      self.base_amount + self.donation_amount
    end

    def set_amounts
        self.base_amount = (self.product.base_price * 100).ceil
        self.donation_amount = (self.product.default_donation_amount * 100).ceil
    end

    #This is to help compare two items to see if they are identical
    def options_hash
        the_hash = self.product_id.to_s + self.is_discount.to_s
        
        self.options.order(:option_group_id).each do |o|
            the_hash += "#{o.option_group_id}#{o.value}#{o.price}"
        end
        
        the_hash
    end
end
