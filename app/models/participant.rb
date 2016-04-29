
class Participant< ActiveRecord::Base
  belongs_to :party,foreign_key: "parties_id"
  belongs_to :order,foreign_key: "orders_id"
  scope :completed, -> { where(status: [1]) }
end