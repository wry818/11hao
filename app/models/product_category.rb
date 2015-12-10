# encoding utf-8
class ProductCategory< ActiveRecord::Base

    validates_presence_of :name, :message => "名称不能为空"
    validates_format_of :sort_mark, :with => /^\d{0,5}$/, multiline: true, :message => "排序码必须是5位以下数字"

    scope :root_product_category,->{where("product_category_id<?",1)}
    scope :isnot_destroy,->{where(:is_destroy => false)}
    scope :is_active,->{where(:active => true)}
    scope :showall,->{where(:active => true).where(:is_destroy => false)}
    scope :showroot,->{where(:active => true).where(:is_destroy => false).where('product_category_id<?',1)}

    has_many :product_categories,->{where(:is_destroy => false).where('product_category_id>?',0)}
    belongs_to :product_category
end