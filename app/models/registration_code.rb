class RegistrationCode < ActiveRecord::Base
  belongs_to :order
  belongs_to :item
  belongs_to :product
end
