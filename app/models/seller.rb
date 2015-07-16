class Seller < ActiveRecord::Base

    belongs_to :user_profile
    belongs_to :campaign
    
    has_many :orders
    has_many :ent_orders
    has_many :email_share_histories
    has_many :social_share_histories
    
    before_create :set_referral_code

    scope :sorted, -> { joins(:user_profile).order('user_profiles.first_name') }

    def supporters
        orders.completed.online.count
    end

    def total_orders
        orders.completed.count
    end

    def total_raised
        (orders.completed.joins(:items).sum('items.quantity * items.donation_amount') + orders.completed.sum('direct_donation') )/ 100.0
    end
    
    def total_sales
        (orders.completed.joins(:items).sum('items.quantity * (items.base_amount + items.donation_amount)') + orders.completed.sum('direct_donation') )/ 100.0
    end
    
    def progress_percent
      if self.campaign.seller_goal.nil? || self.campaign.seller_goal == 0 
        0 
      else
        ((self.total_raised / self.campaign.seller_goal) * 100).ceil
      end
    end
    
    private

    def set_referral_code
        code = ('a'..'z').to_a.shuffle[0,2].join + rand.to_s[2..4]

        while Seller.where(referral_code: code).count > 0 do
            code = ('a'..'z').to_a.shuffle[0,2].join + rand.to_s[2..4]
        end

        self.referral_code = code
    end

end
