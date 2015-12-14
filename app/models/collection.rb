class Collection < ActiveRecord::Base
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    # Try building a slug based on the following fields in
    # increasing order of specificity.
    def slug_candidates
        [
            :name,
            [:name, "#{Collection.where(name: name).count + 1}"]
        ]
    end

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
