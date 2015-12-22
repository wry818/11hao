class AddTargeUrlToSliderImage < ActiveRecord::Migration
  def change
    add_column :mall_slider_images,:target_url,:string
  end
end
