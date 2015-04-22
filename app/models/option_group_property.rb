class OptionGroupProperty < ActiveRecord::Base
  belongs_to :option_group
  
  scope :active, -> { where(deleted: false).order(:sort_order) }
  
  # self.price already exists and is used as base price
  def total_price
    self.price + self.donation_amount
  end
  
  def can_be_ordered?(qty_to_order)
    ret = true
    
    if self.need_check_inventory
      if self.inventory_last_update_time.nil?
        ret = false
      else
        ret = (self.qty_available - self.qty_counter - qty_to_order >= 0)
      end
    end
    
    ret
  end
  
  def need_check_inventory
    self.option_group.product.vendor=="Budco"
  end
end
