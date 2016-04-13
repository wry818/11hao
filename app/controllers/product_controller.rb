class ProductController < ApplicationController
  layout "shop_weixin"
  def index
    if !params[":id"]
      params[":id"]="default"
    end
    @campaign=Campaign.find_by_slug(params[":id"]);
  end
end
