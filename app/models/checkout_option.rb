class CheckoutOption < ActiveRecord::Base
    belongs_to :order
    belongs_to :checkout_option_group
end
