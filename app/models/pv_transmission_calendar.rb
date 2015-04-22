class PVTransmissionCalendar < ActiveRecord::Base
  scope :deliverable, -> { where('submission_date >= ?', Date.today) }
end
