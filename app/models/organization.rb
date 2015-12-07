class Organization < ActiveRecord::Base
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    belongs_to :country
    belongs_to :state_province
    
    validates :name, presence: true
    paginates_per 10
    scope :active, -> { where(:deleted=>false) }

    has_many :organization_roles
    #has_many :users, -> { distinct }, through: :organization_roles
    has_and_belongs_to_many :users
    has_many :campaigns, -> { where(:is_destroy=>false) }

    def has_rep?
        self.legal_rep_first_name.present? && self.legal_rep_last_name.present? && self.legal_rep_phone.present?
    end

    def has_bank?
        self.routing_number.present? && self.account_number.present?
    end
end
