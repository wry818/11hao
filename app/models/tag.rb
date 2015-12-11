class Tag < ActiveRecord::Base

    scope :isnot_destroy,->{where(:is_destroy => false)}
    scope :is_active,->{where(:active => true)}

    has_many :product_tagses
    has_many :products,through: :product_tagses
end
