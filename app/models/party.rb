class Party< ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_many :participants,foreign_key: "parties_id"




  def participants_count
    self.participants.where(:status => 1).count
  end
  def participants_count_surplus
    counttemp=0;
    if self.max_count&&self.max_count!=0
      counttemp=self.max_count - self.participants.where(:status => 1).count
    else
      counttemp=-1
    end
    counttemp
  end

  def days_remaining
    days = 0
    days = (self.register_end.to_date - Date.current).to_i if self.register_end.present?
    days > 0 ? days : 0
  end
  def progress_percent
    if self.max_count.nil? || self.max_count == 0

    else
      p = (self.participants.completed.count/ self.max_count) * 100

      if p == 0
        0
      else
        if p > 1
          p.to_i
        else
          p.ceil
        end
      end
    end
  end
  def format_location
    str=""
    if self.provice
      str+="#{self.provice}/"
    end
    if self.city
      str+="#{self.city}/"
    end
    if self.country
      str+="#{self.country}"
    end
    str
  end
end