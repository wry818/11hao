class Tag < ActiveRecord::Base
    has_many :product_tagses
    has_many :products,through: :product_tagses
end
