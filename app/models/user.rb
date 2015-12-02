class User < ActiveRecord::Base

    # ACCOUNT TYPES
    # Possible values for the account_type field:
    # 1 - A seller that is 18+ (controls her own account)
    # 2 - A seller that is 14-17 (controls her own account, but parent name & email are collected for notifications)
    # 3 - A parent (will have one or more child_profiles associated)

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

    has_many :organization_roles
    #has_many :organizations, -> { distinct }, through: :organization_roles
    has_and_belongs_to_many :organizations
    has_many :campaigns, foreign_key: 'organizer_id'

    has_many :user_profiles
    has_many :contacts
    
    scope :real, -> { where("id>0 and is_fake=false") }
    scope :isnot_destroy,->{ where(is_destroy: false)}
    
    # All users should have at least one user_profile associated which represents their primary profile
    def profile
        self.user_profiles.where(child_profile: false).first
    end

    # A user may have 0 to many child_profiles associated  |  Only users with account_type == 3 should have child profiles
    def child_profiles
        self.user_profiles.where(child_profile: true)
    end

    def is_seller?(campaign)
        Seller.where(campaign_id: campaign.id).where(user_profile_id: self.user_profiles.map(&:id)).count >0
    end
    
    def any_seller?
        Seller.where(user_profile_id: self.user_profiles.map(&:id)).count >0  
    end

    def is_chairperson?
        self.campaigns.count > 0
    end

    def is_sales?
        self.account_type == 4
    end
    
    def is_crs?
        self.account_type == 5
    end
    
    def admin?
        self.admin_flag
    end

end
