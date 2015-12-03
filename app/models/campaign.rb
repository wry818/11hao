class Campaign < ActiveRecord::Base
    
    # enum campaign_mode: [:Fundraising, :Compassion]
    
    # CAMPAIGN TYPES
    # Possible values for the campaign_type field:
    # 1 - A standard raisy campaign that uses the raisy shopping cart.  Will have an associated collection and orders.
    # 2 - An entertainment campaign that links to the entertainment shopping cart.  No associated collection.  Has associated ent_orders that are imported nightly

    # CAMPAIGN MODE
    Fundraising = 1
    Compassion = 2
    
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged
    
    paginates_per 12

    scope :active, -> { where('(end_date is null or end_date >= ?) and active=true', Time.current) }
    scope :ended, -> { where('end_date < ? and active=true', Time.current) }
    scope :normal, -> { where(:campaign_type=>0) }
    scope :storefronts, -> { where(:campaign_type=>2) }
    scope :isnot_destroy, -> { where(:is_destroy=>false) }

    belongs_to :collection,->{where is_destroy: false}
    belongs_to :organizer, class_name: "User"
    belongs_to :organization

    has_many :orders
    has_many :ent_orders 
    has_many :checkout_option_groups 
    has_many :sellers
    has_many :campaign_images
    has_many :campaign_bulkshippinginfos
    has_many :contacts
    
    validates :title, presence: true
    
    def slug_candidates
      [
        :title,
        [:title, :title_count],
        [:title, :title_count, :title_random]
      ]
    end
    
    def title_count
      Campaign.where(:title=>self.title).count
    end
    
    def title_random
      rand(1..9)
    end

    def days_remaining
        days = 0
        days = (self.end_date.to_date - Date.current).to_i if self.end_date.present?
        days > 0 ? days : 0
    end

    def expired?
        (self.end_date.present? && self.end_date < Time.current)
    end

    def supporters
        self.orders.completed.online.count
    end
    
    def completed
        self.orders.completed.count
    end

    def raised
        (self.orders.completed.joins(:items).sum('items.quantity * items.donation_amount') + self.orders.completed.sum('direct_donation') ) / 100.0
    end
    
    def saled
        (self.orders.completed.joins(:items).sum('items.quantity * (items.base_amount + items.donation_amount)') + self.orders.completed.sum('direct_donation') ) / 100.0
    end

    def progress_percent
      if self.goal.nil? || self.goal == 0 
        0 
      else
        ((self.raised / self.goal) * 100).ceil
      end
    end

    def goal_met?
        self.raised >= self.goal
    end

    def delivery_type
        if self.has_shipping
            if self.has_pickup
                3 #shipping or pickup
            else
                2 #just shipping
            end
        elsif self.has_pickup
            1 #just pickup
        else
            0 #just digital delivery
        end
    end

    def ent_campaign?
        self.campaign_type == 2
    end
    
    def active?
        self.active == true
    end

    def donation_percentage
        if ent_campaign?
            40
        elsif collection.present?
            collection.donation_percentage
        else
            100
        end
    end
    
    def campaign_logo
      self.campaign_images.where(:is_logo=>true).first
    end
    
    def campaign_photos
      self.campaign_images.where(:is_logo=>false, :active=>true).order(:id)
    end

    def any_bulkshipping_product?
      if self.collection && self.collection.products
        self.collection.products.where(:fulfillment_method=>3).count >0
      else
        false
      end
    end
    
    def is_discount?
        # !self.discount.nil? && !self.purchase_limit.nil? && (self.purchase_limit-self.discount_counter>0)
        
        true  # always discount
    end
    
    private

    def end_date_cannot_be_in_the_past
        if self.end_date_changed? && !self.end_date.blank? && self.end_date < Time.current
            errors.add(:end_date, "can't be in the past")
        end
    end

end
