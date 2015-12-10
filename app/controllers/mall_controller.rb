class MallController < ApplicationController
  layout "mall"
  
  def home
    @products = Product.first(6)
  end
end