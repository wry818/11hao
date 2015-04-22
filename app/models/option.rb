class Option < ActiveRecord::Base
    belongs_to :item
    belongs_to :option_group
    belongs_to :option_group_property
end
