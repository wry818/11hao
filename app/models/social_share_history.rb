class SocialShareHistory < ActiveRecord::Base
  
  # self.media_id: 1-facebook, 2-twitter

  belongs_to :seller

end
