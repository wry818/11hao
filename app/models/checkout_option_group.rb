class CheckoutOptionGroup < ActiveRecord::Base
    belongs_to :campaign
    has_many :checkout_option_group_properties
    has_many :checkout_options

    scope :everybody, -> { where(deleted: false, buyer_scope: 0).order(:sort_order) }
    scope :pickup, -> { where(deleted: false, buyer_scope: 1).order(:sort_order) }
    scope :shipping, -> { where(deleted: false, buyer_scope: 2).order(:sort_order) }

    def is_dropdown?
        self.checkout_option_group_properties.count > 0
    end
end
