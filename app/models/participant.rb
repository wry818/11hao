
class Participant< ActiveRecord::Base
  belongs_to :party,foreign_key: "parties_id"

  scope :completed, -> { where(status: [1]) }
end