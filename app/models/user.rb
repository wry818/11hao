# encoding: utf-8
class User < ActiveRecord::Base
    # ACCOUNT TYPES
    # Possible values for the account_type field:
    # 1 - A seller that is 18+ (controls her own account)
    # 2 - A seller that is 14-17 (controls her own account, but parent name & email are collected for notifications)
    # 3 - A parent (will have one or more child_profiles associated)

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable

    validates_presence_of :email,message:'邮箱不能为空'
    validates :email, uniqueness: {scope: :is_destroy,message:'邮箱已注册请重新输入'}

    validates_presence_of :password,message: '密码不能为空'
    validates_length_of :password, within: 8..20,message:'密码长度必须是8到20'
    validates_confirmation_of :password,  :message => "两次密码不一致!"

    # validates :email,->{where(is_destroy:false) }
    # validates :email, uniqueness: {scope: :shop_id}, format: {with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/ }, if: :email_changed?

    has_many :organization_roles
    #has_many :organizations, -> { distinct }, through: :organization_roles
    has_and_belongs_to_many :organizations
    has_many :campaigns,->{where is_destroy: false}, foreign_key: 'organizer_id'

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
