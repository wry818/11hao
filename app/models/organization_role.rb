class OrganizationRole < ActiveRecord::Base
    belongs_to :organization
    belongs_to :user
    validates :organization_id, uniqueness: { scope: :user_id }
end
