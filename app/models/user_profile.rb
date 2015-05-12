class UserProfile < ActiveRecord::Base

    belongs_to :user
    has_many :sellers

    validates :first_name, presence: true

    before_create :set_default_image

    def set_names(fullname)
        self.first_name = fullname.split(' ', 2)[0]
        self.last_name = fullname.split(' ', 2)[1]
    end

    def shortname
      first_name || ""
    end

    def fullname
      first_name || ""
    end
    
    def parent_fullname
      if self.user.account_type==3
        if self.child_profile
          self.user.profile.fullname
        else
          ""
        end
      else
        self.parent_first_name.present? && self.parent_last_name.present? ? "#{self.parent_first_name} #{self.parent_last_name}" : (self.parent_first_name || "")
      end
    end
    
    def seller(campaign)
        self.sellers.where(campaign_id: campaign.id, user_profile_id: self.id).first
    end

    private

    def set_default_image
        self.picture = '' if picture.blank?
    end
end
