class Tag < ActiveRecord::Base

    scope :isnot_destroy,->{where(:is_destroy => false)}
    scope :is_active,->{where(:active => true)}

    has_many :product_tagses,class_name: "ProductTags",foreign_key: "tag_id", dependent: :destroy
    has_many :products,through: :product_tagses
end
