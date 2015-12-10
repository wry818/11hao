class Product < ActiveRecord::Base
    extend FriendlyId
    
    friendly_id :name, use: :slugged

    scope :isnot_destroy,->{where(is_destroy:false)}

    has_and_belongs_to_many :collections
    has_and_belongs_to_many :categories
    has_many :items
    has_many :option_groups
    has_many :product_images
    belongs_to :product_category,->{where(:is_destroy => false)},foreign_key: "product_category_id"
    belongs_to :pro_cat_subclass,->{where(:is_destroy => false)},class_name: "ProductCategory",foreign_key: "pro_cat_subclass_id"


    validates :base_price, :default_donation_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
    
    # fulfillment_method
    # 1 = email, 2 = shipping immediately, 3 = bulk shipping at campaign closing
    
    def can_be_ordered?(qty_to_order)
      ret = true
      
      if self.need_check_inventory
        if self.inventory_last_update_time.nil?
          ret = false
        else
          ret = (self.qty_available - self.qty_counter - qty_to_order >= 0)
        end
      end
      
      ret
    end
    
    def need_check_inventory
      self.vendor=="Budco"
    end
    
    def need_sku
      self.vendor=="Budco" || self.vendor=="PV"
    end
    
    def delivery_method
      case fulfillment_method
        when 1
            'Email'
        when 2
            'Shipping'
        when 3
            'Bulk Shipping'
        else
            ''
      end
    end

    def total_price
        self.base_price + self.default_donation_amount
    end
    
    def total_original_price
        self.original_price + self.default_donation_amount
    end
    
    def price_range(discount)
      min = (self.original_price * 100).ceil/100.0
      max = (self.original_price * 100).ceil/100.0
      discount_min = (self.total_price * 100).ceil/100.0
      discount_max = (self.total_price * 100).ceil/100.0
      option_group_is_dropdown = false
      
      option_group = self.option_groups.active.first
      
      if option_group
          min = 99999
          max = 0
          discount_min = 99999
          discount_max = 0
          
          has_properties = false
          
          option_group.option_group_properties.active.each do |property|
            option_group_is_dropdown = true
          
            if property.can_be_ordered?(1)
                has_properties = true
                
                prop_price = (self.original_price * 100).ceil/100.0
                discount_prop_price = (property.total_price * 100).ceil/100.0
                
                if prop_price<=min
                  min=prop_price
                end

                if prop_price>=max
                  max=prop_price
                end

                if discount_prop_price<=discount_min
                  discount_min=discount_prop_price
                end

                if discount_prop_price>=discount_max
                  discount_max=discount_prop_price
                end
              end
          end
          
          if !has_properties
              min = (self.original_price * 100).ceil/100.0
              max = (self.original_price * 100).ceil/100.0
              discount_min = (self.total_price * 100).ceil/100.0
              discount_max = (self.total_price * 100).ceil/100.0
          end
      else
          min = (self.original_price * 100).ceil/100.0
          max = (self.original_price * 100).ceil/100.0
          discount_min = (self.total_price * 100).ceil/100.0
          discount_max = (self.total_price * 100).ceil/100.0
      end
      
      {:min=>min, :max=>max, :discount_min=>discount_min, :discount_max=>discount_max,
          :same_price=>(min==max), :same_discount_price=>(discount_min==discount_max),
          :is_discount=>true
      }
    end
    
    def cover_photo
      self.product_images.where(:is_cover=>true).first
    end
    
    def more_photo
      self.product_images.where(:is_cover=>false).order(:id)
    end
    
    def all_photo
      self.product_images.order(:is_cover=>:desc).order(:id)
    end
end
