class Organization < ActiveRecord::Base
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    # Try building a slug based on the following fields in
    # increasing order of specificity.
    def slug_candidates
        [
            :name,
            [:name, "#{Organization.where(name: name).count + 1}"]
        ]
    end
    
    belongs_to :country
    belongs_to :state_province
    
    validates :name, presence: true
    paginates_per 10
    scope :active, -> { where(:deleted=>false) }

    has_many :organization_roles
    #has_many :users, -> { distinct }, through: :organization_roles
    has_and_belongs_to_many :users
    has_many :campaigns, -> { where(:is_destroy=>false) }

    has_many :questionnaires

    def has_rep?
        self.legal_rep_first_name.present? && self.legal_rep_last_name.present? && self.legal_rep_phone.present?
    end

    def has_bank?
        self.routing_number.present? && self.account_number.present?
    end
end
