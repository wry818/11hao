class Collection < ActiveRecord::Base
    extend FriendlyId
    friendly_id :name, use: :slugged

    scope :active, -> { where(active: true).order(:sort_order) }
    scope :isnot_destroy,->{where(is_destroy:false)}

    has_many :categories, :dependent => :destroy
    has_and_belongs_to_many :products,->{where is_destroy: false}
    has_many :campaigns

    validates :name, presence: true

    def tile_size
        #if the number of products is greater than 4, return 4 (puts 3 tiles per row)
        #if the number of products is less than or equal to 4, return 6 (puts 2 tiles per row)
        self.products.count > 4 ? 4 : 6
    end

end
