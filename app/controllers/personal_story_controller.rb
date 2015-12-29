class PersonalStoryController < ApplicationController

  layout "story"
  def index
    @order=Order.find(1)
  end
end
