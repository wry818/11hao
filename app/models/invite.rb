class Invite < ActiveRecord::Base
    validates :email, presence: true, email: true
    belongs_to :collection
end
