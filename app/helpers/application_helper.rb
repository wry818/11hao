module ApplicationHelper
    def short_price(price)
        if price.to_i == price
            number_with_delimiter(price.to_i, :delimiter => ',')
        else
            number_with_precision(price, :precision => 2, :delimiter => ',')
        end
    end

    def long_price(price)
        number_with_precision(price, :precision => 2, :delimiter => ',')
    end
    
    def mask_phone_number(num)
      num = num || ""
      
      if num.length>=7
        num = num[0,3] + "****" + num[-4,4]
      end
      
      num
    end


end
