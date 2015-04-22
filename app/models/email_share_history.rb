class EmailShareHistory < ActiveRecord::Base

    belongs_to :contact
    belongs_to :seller

end
