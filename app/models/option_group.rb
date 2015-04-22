class OptionGroup < ActiveRecord::Base
    belongs_to :product
    has_many :option_group_properties
    has_many :options

    scope :active, -> { where(deleted: false).order(:sort_order) }

    def is_dropdown?
        self.option_group_properties.active.count > 0
    end
end
