class EntOrder < ActiveRecord::Base
    belongs_to :campaign
    belongs_to :seller

    def purchaser_fullname
        "#{purchaser_first_name} #{purchaser_last_name}"
    end

end
