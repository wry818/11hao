class Category < ActiveRecord::Base
    extend FriendlyId
    friendly_id :slug_candidates, use: :slugged

    # Try building a slug based on the following fields in
    # increasing order of specificity.
    def slug_candidates
        [
            :name,
            [:name, "#{Category.where(name: name).count + 1}"]
        ]
    end
    belongs_to :collection

    has_many :subcategories, class_name: 'Category', foreign_key: 'parent_category_id'
    belongs_to :parent, class_name: 'Category', foreign_key: 'parent_category_id'

    has_and_belongs_to_many :products

    def parents
        parents = []
        continue = true
        while (continue)
            if self.parent
                parents << self.parent
            else
                continue = false
            end
        end
        parents
    end

end
