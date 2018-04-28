class AddShopUrls < ActiveRecord::Migration
  def change
    create_table :shop_urls do |t|
        t.string :url

      t.timestamps
    end
  end
end
