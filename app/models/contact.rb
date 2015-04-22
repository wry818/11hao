class Contact < ActiveRecord::Base
    
    # media_id: 1-gmail, 2-yahoo, 3-hotmail, 4-facebook, 5-manual
    
    belongs_to :user
    has_many :email_share_histories
    
    def fullname
      first_name.present? && last_name.present? ? "#{first_name} #{last_name}" : (first_name || "")
    end
end
