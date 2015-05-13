class Vendor < ActiveRecord::Base
  scope :active, -> { where(:deleted=>false, :active=>true) }
end
