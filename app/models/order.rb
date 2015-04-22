class Order < ActiveRecord::Base

    scope :completed, -> { where(status: [1, 3]) }
    scope :online, -> { where(is_offline: false) }

    belongs_to :campaign
    has_many :items
    belongs_to :seller
    belongs_to :team_member
    has_many :checkout_options
    
    def completed?
      [1, 3].include?(self.status)
    end

    def calculate_fees!
        self.shipping_fee = 0
        self.processing_fee_supporter = 0
        self.processing_fee_organization = 0

        if delivery_method == 2
            items = self.num_items
            flat = self.campaign.shipping_flat_rate || 0
            variable = self.campaign.shipping_variable_rate || 0
            self.shipping_fee = ((flat + (items - 1) * variable)*100.0).ceil
        end

        processing_fee_amount = ((subtotal + shipping_fee)*Rails.configuration.processing_fee_variable).ceil + Rails.configuration.processing_fee_fixed
        if self.campaign.charge_processing_to_supporter
            self.processing_fee_supporter = processing_fee_amount
        end
        if self.campaign.charge_processing_to_organization
            self.processing_fee_organization = processing_fee_amount
        end
        save
    end

    def valid_order?
        self.items.count > 0 || self.donation_only?
    end

    def donation_only?
        self.items.count == 0 && self.direct_donation > 0
    end

    def subtotal
        self.base_total + self.donation_total
    end

    def base_total
        self.items.sum('items.base_amount * items.quantity') || 0
    end

    def donation_total
        (self.items.sum('items.donation_amount * items.quantity') + self.direct_donation) || 0
    end

    def grandtotal
        self.subtotal + shipping_fee + processing_fee_supporter
    end

    def num_items
        self.items.sum('items.quantity')
    end

    def delivery_method_text
        case delivery_method
        when 2
            'shipping'
        when 1
            'pick-up'
        when 0
            'email'
        else
            'email'
        end
    end

    def needs_shipping
        result = false
        self.items.each do |i|
            if i.delivery_method==2
                result = true
            end
        end
        result
    end
    
    def needs_email
        result = false
        self.items.each do |i|
            if i.delivery_method==1
                result = true
            end
        end
        result
    end
    
    def needs_bulkshipping
        result = false
        self.items.each do |i|
            if i.delivery_method==3
                result = true
            end
        end
        result
    end

    def status_text
        status_text = %w(pending authorized canceled charged rejected refunded)
        status_text[self.status]
    end

    def status_class
        status_class = ['', '', 'danger', 'success', 'danger', 'warning']
        status_class[self.status]
    end

    def update_payment_api_data(response)
        self.charge_id = response.charge_id
        self.card_type = response.card_type
        self.card_last_four = response.card_last4
        self.card_expiration_month = response.card_expiration_month
        self.card_expiration_year = response.card_expiration_year
    end
    
    def delivery_single_line_address
      addr_one = self.address_line_one || ""
      addr_two = self.address_line_two || ""
      city = self.address_city || ""
      state = self.address_state || ""
      zip = self.address_postal_code || ""
      country = self.address_country || ""
      
      addr_one + (addr_two=="" ? "" : ", " + addr_two) + (city=="" ? "" : ", " + city) +
        (state=="" ? "" : ", " + state) + (zip=="" ? "" : ", " + zip) + 
        (country=="" ? "" : " " + country)
    end
end

class PaymentApiResponse 
  def charge_id
    @charge_id
  end
  
  def charge_id=(val)
    @charge_id = val
  end
  
  def card_type
    @card_type
  end
  
  def card_type=(val)
    @card_type = val
  end
  
  def card_last4
    @card_last4
  end
  
  def card_last4=(val)
    @card_last4 = val
  end
  
  def card_expiration_month
    @card_expiration_month
  end
  
  def card_expiration_month=(val)
    @card_expiration_month = val
  end
  
  def card_expiration_year
    @card_expiration_year
  end
  
  def card_expiration_year=(val)
    @card_expiration_year = val
  end
  
  def success?
    @success
  end
  
  def success=(val)
    @success = val
  end
  
  def message
    @message
  end
  
  def message=(val)
    @message = val
  end
end
